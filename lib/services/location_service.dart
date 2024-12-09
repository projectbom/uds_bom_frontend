import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:js' as js;
import 'dart:math' show cos, sin, sqrt, atan2, pi;
import '../models/location.dart';
import '../models/transportation.dart';

class LocationService {
  final String _googleApiKey = 'YOUR_GOOGLE_API_KEY'; // API 키 설정 필요

  Future<Location> getCurrentLocation() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled) {
        throw Exception('위치 서비스가 비활성화되어 있습니다');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('위치 권한이 거부되었습니다');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: 'ko_KR',
      );

      if (placemarks.isEmpty) {
        throw Exception('주소를 찾을 수 없습니다');
      }

      final placemark = placemarks[0];
      final address = _formatAddress(placemark);

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      throw Exception('위치를 가져오는데 실패했습니다: $e');
    }
  }

  String _formatAddress(geocoding.Placemark placemark) {
    final List<String> addressParts = [];

    if (placemark.street?.isNotEmpty ?? false) {
      addressParts.add(placemark.street!);
    }
    if (placemark.locality?.isNotEmpty ?? false) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.subLocality?.isNotEmpty ?? false) {
      addressParts.add(placemark.subLocality!);
    }

    return addressParts.isEmpty ? '알 수 없는 주소' : addressParts.join(' ');
  }

  Future<Location> searchAddress(String query) async {
    if (query.trim().isEmpty) {
      throw Exception('검색어를 입력해주세요');
    }

    try {
      final locations = await geocoding.locationFromAddress(
        query,
        localeIdentifier: 'ko_KR',
      );

      if (locations.isEmpty) {
        throw Exception('검색 결과가 없습니다');
      }

      final location = locations.first;
      final placemarks = await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
        localeIdentifier: 'ko_KR',
      );

      final address =
          placemarks.isNotEmpty ? _formatAddress(placemarks[0]) : query;

      return Location(
        latitude: location.latitude,
        longitude: location.longitude,
        address: address,
      );
    } catch (e) {
      throw Exception('주소를 검색하는데 실패했습니다: $e');
    }
  }

  Future<List<LatLng>> getRoutePoints(
    Location start,
    Location end,
    TransportationType type,
  ) async {
    final mode = type == TransportationType.car ? 'driving' : 'transit';
    final url = Uri.parse('https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${start.latitude},${start.longitude}'
        '&destination=${end.latitude},${end.longitude}'
        '&mode=$mode'
        '&key=$_googleApiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final points =
              _decodePolyline(data['routes'][0]['overview_polyline']['points']);
          return points;
        }
      }
      throw Exception('경로를 가져오는데 실패했습니다');
    } catch (e) {
      throw Exception('경로 검색 오류: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<Duration> calculateTravelTime(
    Location origin,
    Location destination,
    TransportationType transportType,
  ) async {
    try {
      final directionsService =
          js.context['google']['maps']['DirectionsService']();

      final request = {
        'origin': {'lat': origin.latitude, 'lng': origin.longitude},
        'destination': {
          'lat': destination.latitude,
          'lng': destination.longitude
        },
        'travelMode': transportType == TransportationType.car
            ? js.context['google']['maps']['TravelMode']['DRIVING']
            : js.context['google']['maps']['TravelMode']['TRANSIT']
      };

      final result = await js.context
          .callMethod('getDirections', [directionsService, request]);

      if (result != null && result['routes'].length > 0) {
        final route = result['routes'][0]['legs'][0];
        // Google API가 제공하는 소요시간을 바로 사용
        return Duration(seconds: route['duration']['value']);
      }

      throw Exception('경로를 찾을 수 없습니다');
    } catch (e) {
      throw Exception('이동 시간 계산 실패: $e');
    }
  }

  Location calculateMidPoint(List<Location> locations) {
    if (locations.isEmpty) {
      throw Exception('위치 정보가 없습니다');
    }

    if (locations.length == 1) {
      return locations.first;
    }

    List<double> latRadians =
        locations.map((loc) => _toRadians(loc.latitude)).toList();
    List<double> lngRadians =
        locations.map((loc) => _toRadians(loc.longitude)).toList();

    List<_CartesianPoint> cartesianPoints = [];
    for (int i = 0; i < locations.length; i++) {
      cartesianPoints.add(_toCartesian(latRadians[i], lngRadians[i]));
    }

    _CartesianPoint center = _CartesianPoint(
      x: cartesianPoints.map((p) => p.x).reduce((a, b) => a + b) /
          locations.length,
      y: cartesianPoints.map((p) => p.y).reduce((a, b) => a + b) /
          locations.length,
      z: cartesianPoints.map((p) => p.z).reduce((a, b) => a + b) /
          locations.length,
    );

    final magnitude =
        sqrt(center.x * center.x + center.y * center.y + center.z * center.z);
    center = _CartesianPoint(
      x: center.x / magnitude,
      y: center.y / magnitude,
      z: center.z / magnitude,
    );

    double centerLng = atan2(center.y, center.x);
    double centerLat = atan2(
      center.z,
      sqrt(center.x * center.x + center.y * center.y),
    );

    return Location(
      latitude: _toDegrees(centerLat),
      longitude: _toDegrees(centerLng),
      address: '중간 지점',
    );
  }

  double _toRadians(double degrees) => degrees * pi / 180;
  double _toDegrees(double radians) => radians * 180 / pi;
}

class _CartesianPoint {
  final double x;
  final double y;
  final double z;

  _CartesianPoint({required this.x, required this.y, required this.z});

  factory _CartesianPoint.fromSpherical(double lat, double lng) {
    final double r = cos(lat);
    return _CartesianPoint(
      x: r * cos(lng),
      y: r * sin(lng),
      z: sin(lat),
    );
  }

  double get magnitude => sqrt(x * x + y * y + z * z);

  _CartesianPoint normalized() {
    final m = magnitude;
    return _CartesianPoint(
      x: x / m,
      y: y / m,
      z: z / m,
    );
  }
}

_CartesianPoint _toCartesian(double lat, double lng) {
  return _CartesianPoint.fromSpherical(lat, lng);
}
