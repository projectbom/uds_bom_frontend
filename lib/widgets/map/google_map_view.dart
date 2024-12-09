import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:js' as js;
import 'dart:math' as math;
import '../../models/user.dart';
import '../../models/meeting_point.dart';
import '../../models/transportation.dart';
import '../../services/location_service.dart';

class GoogleMapView extends StatefulWidget {
  final List<User> users;
  final MeetingPoint? meetingPoint;

  const GoogleMapView({
    Key? key,
    required this.users,
    this.meetingPoint,
  }) : super(key: key);

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isMapLoaded = false;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _updateMapMarkers();
  }

  @override
  void didUpdateWidget(GoogleMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMapMarkers();
    if (_mapController != null && _markers.isNotEmpty) {
      _fitBounds();
    }
  }

  Future<void> _updateMapMarkers() async {
    if (!mounted) return;

    final Set<Marker> newMarkers = {};
    final Set<Polyline> newPolylines = {};

    // 사용자 마커 추가
    for (var user in widget.users) {
      if (user.location != null) {
        try {
          final marker = await js.context.callMethod('createAdvancedMarker', [
            {
              'lat': user.location!.latitude,
              'lng': user.location!.longitude
            },
            user.name,
            '${user.transportType == TransportationType.car ? '자가용' : '대중교통'}\n${user.location!.address}',
            'user'
          ]);

          if (marker != null) {
            newMarkers.add(Marker(
              markerId: MarkerId('user_${user.id}'),
              position: LatLng(user.location!.latitude, user.location!.longitude),
              infoWindow: InfoWindow(
                title: user.name,
                snippet: '${user.transportType == TransportationType.car ? '자가용' : '대중교통'}\n${user.location!.address}',
              ),
            ));
          }
        } catch (e) {
          print('마커 생성 오류: $e');
        }
      }
    }

    // 중간 지점 마커와 경로 추가
    if (widget.meetingPoint != null) {
      try {
        final meetingMarker = await js.context.callMethod('createAdvancedMarker', [
          {
            'lat': widget.meetingPoint!.location.latitude,
            'lng': widget.meetingPoint!.location.longitude
          },
          '중간 지점',
          widget.meetingPoint!.location.address,
          'meeting'
        ]);

        if (meetingMarker != null) {
          newMarkers.add(Marker(
            markerId: const MarkerId('meeting_point'),
            position: LatLng(
              widget.meetingPoint!.location.latitude,
              widget.meetingPoint!.location.longitude,
            ),
            infoWindow: InfoWindow(
              title: '중간 지점',
              snippet: widget.meetingPoint!.location.address,
            ),
          ));

          // 경로 추가
          for (var user in widget.users) {
            if (user.location != null) {
              try {
                final routePoints = await _locationService.getRoutePoints(
                  user.location!,
                  widget.meetingPoint!.location,
                  user.transportType,
                );

                newPolylines.add(Polyline(
                  polylineId: PolylineId('route_${user.id}'),
                  points: routePoints,
                  color: user.transportType == TransportationType.car
                      ? Colors.blue.withOpacity(0.6)
                      : Colors.green.withOpacity(0.6),
                  width: 3,
                ));
              } catch (e) {
                print('경로 생성 오류: $e');
              }
            }
          }
        }
      } catch (e) {
        print('중간 지점 마커 생성 오류: $e');
      }
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
        _polylines = newPolylines;
      });
    }
  }

  void _fitBounds() {
    if (_markers.isEmpty) return;

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final marker in _markers) {
      minLat = math.min(minLat, marker.position.latitude);
      maxLat = math.max(maxLat, marker.position.latitude);
      minLng = math.min(minLng, marker.position.longitude);
      maxLng = math.max(maxLng, marker.position.longitude);
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => true,
      child: AbsorbPointer(
        absorbing: false,
        child: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(37.5665, 126.9780),
            zoom: 11.0,
          ),
          markers: _markers,
          polylines: _polylines,
          onMapCreated: (controller) {
            _mapController = controller;
            setState(() => _isMapLoaded = true);
            _fitBounds();
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}