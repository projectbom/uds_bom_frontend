import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/location.dart';
import '../models/meeting_point.dart';
import '../models/place.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../models/transportation.dart';

class MeetingProvider with ChangeNotifier {
  final LocationService _locationService;
  final ApiService _apiService;

  List<User> _participants = [];
  MeetingPoint? _meetingPoint;
  List<Place> _recommendedPlaces = [];
  bool _isLoading = false;

  MeetingProvider({
    LocationService? locationService,
    ApiService? apiService,
  })  : _locationService = locationService ?? LocationService(),
        _apiService = apiService ?? ApiService();

  List<User> get participants => List.unmodifiable(_participants);
  MeetingPoint? get meetingPoint => _meetingPoint;
  List<Place> get recommendedPlaces => List.unmodifiable(_recommendedPlaces);
  bool get isLoading => _isLoading;

  Future<void> addParticipant(User user) async {
    if (_participants.length >= 5) {
      throw Exception('최대 5명까지만 참가할 수 있습니다');
    }

    _participants = [..._participants, user];
    notifyListeners();
    
    if (_participants.length >= 2) {
      _isLoading = true;
      notifyListeners();
      
      try {
        await _updateMeetingPoint();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> removeParticipant(String userId) async {
    _participants = _participants.where((user) => user.id != userId).toList();
    notifyListeners();

    if (_participants.length >= 2) {
      _isLoading = true;
      notifyListeners();
      
      try {
        await _updateMeetingPoint();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    } else {
      _clearMeetingData();
      notifyListeners();
    }
  }

  Future<void> updateParticipant(String userId, User updatedUser) async {
    final index = _participants.indexWhere((user) => user.id == userId);
    if (index == -1) return;

    _participants[index] = updatedUser;
    notifyListeners();

    if (_participants.length >= 2) {
      _isLoading = true;
      notifyListeners();
      
      try {
        await _updateMeetingPoint();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> updateUserLocation(String userId, Location location) async {
    final index = _participants.indexWhere((user) => user.id == userId);
    if (index == -1) return;

    _participants[index] = _participants[index].copyWith(
      location: location,
      isLocationSelected: true,
    );
    notifyListeners();

    if (_participants.length >= 2) {
      _isLoading = true;
      notifyListeners();
      
      try {
        await _updateMeetingPoint();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> updateUserTransportation(String userId, TransportationType type) async {
    final index = _participants.indexWhere((user) => user.id == userId);
    if (index == -1) return;

    _participants[index] = _participants[index].copyWith(
      transportType: type,
    );
    notifyListeners();

    if (_participants.length >= 2) {
      _isLoading = true;
      notifyListeners();
      
      try {
        await _updateMeetingPoint();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _updateMeetingPoint() async {
    if (_participants.length < 2 ||
        _participants.where((user) => user.location != null && user.isLocationSelected).length < 2) {
      _clearMeetingData();
      return;
    }

    try {
      final locations = _participants
          .where((user) => user.location != null && user.isLocationSelected)
          .map((user) => user.location!)
          .toList();

      final midPoint = _locationService.calculateMidPoint(locations);
      
      Map<String, Duration> travelTimes = {};
      for (var user in _participants) {
        if (user.location != null && user.isLocationSelected) {
          final duration = await _locationService.calculateTravelTime(
            user.location!,
            midPoint,
            user.transportType,
          );
          travelTimes[user.id] = duration;
        }
      }

      final places = await _apiService.getNearbyPlaces(
        midPoint,
        radius: 1500,
        types: ['restaurant', 'cafe', 'park'],
      );

      _meetingPoint = MeetingPoint(
        location: midPoint,
        nearbyPlaces: places,
        travelTimes: travelTimes,
        isCalculated: true,
      );
      _recommendedPlaces = places;
      notifyListeners();
    } catch (e) {
      _clearMeetingData();
      rethrow;
    }
  }

  void addInitialParticipants() {
    if (_participants.isEmpty) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      addParticipant(User(
        id: 'user_${timestamp}_1',
        name: '참가자 1',
      ));
    }
  }

  void clear() {
    _participants = [];
    _clearMeetingData();
    notifyListeners();
  }

  void _clearMeetingData() {
    _meetingPoint = null;
    _recommendedPlaces = [];
  }
}