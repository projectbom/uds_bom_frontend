import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:js' as js;
import '../config/constants.dart';
import '../models/place.dart';
import '../models/location.dart';
import '../models/transportation.dart';
import '../models/search_history.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class ApiService {
  final String baseUrl;
  String? apiKey;
  final http.Client _client;

  ApiService({
    this.baseUrl = AppConstants.baseApiUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              if (apiKey != null) 'Authorization': 'Bearer $apiKey',
              if (headers != null) ...headers,
            },
            body: body != null ? json.encode(body) : null,
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('${AppConstants.networkError}: ${e.toString()}');
    }
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          if (headers != null) ...headers,
        },
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('${AppConstants.networkError}: ${e.toString()}');
    }
  }

  // api_service.dart에 추가
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (apiKey != null) 'Authorization': 'Bearer $apiKey',
          if (headers != null) ...headers,
        },
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('${AppConstants.networkError}: ${e.toString()}');
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .patch(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              if (apiKey != null) 'Authorization': 'Bearer $apiKey',
              if (headers != null) ...headers,
            },
            body: body != null ? json.encode(body) : null,
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('${AppConstants.networkError}: ${e.toString()}');
    }
  }

  Future<List<SearchHistory>> getSearchHistory(String userId) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseApiUrl}/search-history/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SearchHistory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String> getApiKey() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl${AppConstants.apiKeyEndpoint}'),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        apiKey = data['api_key'];
        await js.context.callMethod('initializeGoogleMaps', [apiKey]);
        return apiKey!;
      }

      throw _handleError(response);
    } catch (e) {
      throw Exception('API 키를 가져오는데 실패했습니다: ${e.toString()}');
    }
  }

  Future<List<Place>> getNearbyPlaces(
    Location location, {
    List<String>? types,
    int radius = 1500,
  }) async {
    try {
      final service = js.context['google']['maps']['places']
          ['PlacesService'](js.context['map']);

      final List<Place> allPlaces = [];

      for (final type in types ?? ['restaurant', 'cafe']) {
        final request = {
          'location': {'lat': location.latitude, 'lng': location.longitude},
          'radius': radius,
          'type': type,
          'language': 'ko',
          'rankBy': js.context['google']['maps']['places']['RankBy']['RATING']
        };

        final results = await js.context
            .callMethod('searchNearbyPlaces', [service, request]);

        if (results != null) {
          allPlaces.addAll(List<Place>.from(results.map((place) => Place(
                id: place['place_id'],
                name: place['name'],
                type: place['types']?[0] ?? '',
                location: Location(
                  latitude: place['geometry']['location']['lat'],
                  longitude: place['geometry']['location']['lng'],
                  address: place['vicinity'] ?? '',
                ),
                rating: place['rating']?.toDouble() ?? 0.0,
                imageUrl: _getPlacePhotoUrl(place),
                address: place['vicinity'],
                userRatingsTotal: place['user_ratings_total'] ?? 0,
                priceLevel: place['price_level']?.toInt() ?? 0,
              ))));
        }
      }

      // 평점과 리뷰 수를 고려하여 정렬
      allPlaces.sort((a, b) {
        final aScore = (a.rating * 0.7) + ((a.userRatingsTotal / 1000) * 0.3);
        final bScore = (b.rating * 0.7) + ((b.userRatingsTotal / 1000) * 0.3);
        return bScore.compareTo(aScore);
      });

      return allPlaces.take(10).toList();
    } catch (e) {
      throw Exception('주변 장소 검색 오류: $e');
    }
  }

  String? _getPlacePhotoUrl(dynamic place) {
    try {
      if (place['photos'] != null && place['photos'].length > 0) {
        final photoReference = place['photos'][0]['photo_reference'];
        return 'https://maps.googleapis.com/maps/api/place/photo'
            '?maxwidth=400'
            '&photo_reference=$photoReference'
            '&key=$apiKey';
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<LatLng>> getDirections(
      Location origin, Location destination, TransportationType mode) async {
    try {
      final directionsService =
          js.context['google']['maps']['DirectionsService']();

      final request = {
        'origin': {'lat': origin.latitude, 'lng': origin.longitude},
        'destination': {
          'lat': destination.latitude,
          'lng': destination.longitude
        },
        'travelMode': mode == TransportationType.car
            ? js.context['google']['maps']['TravelMode']['DRIVING']
            : js.context['google']['maps']['TravelMode']['TRANSIT']
      };

      final result = await js.context
          .callMethod('getDirections', [directionsService, request]);

      if (result != null && result['routes'].length > 0) {
        final points =
            _decodePolyline(result['routes'][0]['overview_polyline']['points']);
        return points;
      }

      return [];
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

  Exception _handleError(http.Response response) {
    try {
      final error = json.decode(response.body);
      return Exception(
          error['detail'] ?? error['message'] ?? AppConstants.networkError);
    } catch (_) {
      return Exception('HTTP 오류: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}
