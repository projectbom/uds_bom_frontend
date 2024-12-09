import 'package:flutter/foundation.dart';
import '../models/location.dart';
import '../services/location_service.dart';
import '../config/constants.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService;
  Location? _currentLocation;
  bool _isLoading = false;
  List<String> _recentLocations = [];
  String? _lastSearchQuery;

  LocationProvider({LocationService? locationService})
      : _locationService = locationService ?? LocationService();

  Location? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;
  List<String> get recentLocations => List.unmodifiable(_recentLocations);
  String? get lastSearchQuery => _lastSearchQuery;

  Future<void> getCurrentLocation() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final location = await _locationService.getCurrentLocation();
      _currentLocation = location;
      notifyListeners();
    } catch (e) {
      _currentLocation = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Location> searchLocation(String query) async {
    if (_isLoading) {
      throw Exception('이전 검색이 진행 중입니다');
    }

    _isLoading = true;
    _lastSearchQuery = query;
    notifyListeners();

    try {
      final location = await _locationService.searchAddress(query);
      if (location != null) {
        _addRecentLocation(query);
        return location;
      }
      throw Exception('위치를 찾을 수 없습니다');
    } catch (e) {
      _lastSearchQuery = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addRecentLocation(String address) {
    if (address.isEmpty || _recentLocations.contains(address)) {
      return;
    }

    _recentLocations = [
      address,
      ..._recentLocations.take(AppConstants.maxRecentLocations - 1)
    ];
    notifyListeners();
  }

  void clearRecentLocations() {
    if (_recentLocations.isEmpty) return;
    
    _recentLocations = [];
    notifyListeners();
  }

  void setCurrentLocation(Location location) {
    _currentLocation = location;
    notifyListeners();
  }

  Future<void> updateCurrentLocation() async {
    if (_currentLocation == null) {
      await getCurrentLocation();
      return;
    }

    try {
      final updatedLocation = await _locationService.getCurrentLocation();
      if (updatedLocation != null) {
        _currentLocation = updatedLocation;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  void reset() {
    _currentLocation = null;
    _lastSearchQuery = null;
    _isLoading = false;
    notifyListeners();
  }
}