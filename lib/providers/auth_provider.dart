import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import '../models/location.dart';
import '../models/transportation.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  late final StorageService _storageService;
  User? _currentUser;
  bool _isLoading = false;

  AuthProvider({
    AuthService? authService,
    StorageService? storageService,
  }) : _authService = authService ?? AuthService() {
    _initializeStorageService();
  }

  Future<void> _initializeStorageService() async {
    _storageService = await StorageService.getInstance();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser != null) {
        await _storageService.saveUser(_currentUser!);
      }
    } catch (e) {
      _currentUser = await _storageService.getUser();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithEmail(email, password);
      notifyListeners();
    } catch (e) {
      throw Exception('이메일 로그인 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithKakao() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithKakao();
      await _storageService.saveUser(_currentUser!);
      notifyListeners();
    } catch (e) {
      throw Exception('카카오 로그인 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithNaver() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithNaver();
      await _storageService.saveUser(_currentUser!);
      notifyListeners();
    } catch (e) {
      throw Exception('네이버 로그인 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.signInWithGoogle();
      await _storageService.saveUser(_currentUser!);
      notifyListeners();
    } catch (e) {
      throw Exception('구글 로그인 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserLocation(Location location) async {
    if (_currentUser == null) return;

    try {
      final updatedUser = await _authService.updateUser(
        _currentUser!.id,
        {'location': location.toJson()},
      );

      _currentUser = updatedUser;
      await _storageService.saveUser(_currentUser!);
      notifyListeners();
    } catch (e) {
      throw Exception('위치 업데이트 실패: $e');
    }
  }

  Future<void> updateProfileImage(String imageUrl) async {
    if (_currentUser == null) return;

    try {
      if (_currentUser?.profileImageUrl != null) {
        await _storageService.deleteProfileImage(_currentUser!.id);
      }

      final updatedUser = await _authService.updateUser(
        _currentUser!.id,
        {'profileImageUrl': imageUrl},
      );

      _currentUser = updatedUser;
      await _storageService.saveUser(_currentUser!);
      notifyListeners();
    } catch (e) {
      throw Exception('프로필 이미지 업데이트 실패: $e');
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? profileImageUrl,
    Location? location,
    TransportationType? transportType,
  }) async {
    if (_currentUser == null) return;

    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;
      if (location != null) updates['location'] = location.toJson();
      if (transportType != null)
        updates['transportType'] = transportType.toString();

      final updatedUser = await _authService.updateUser(
        _currentUser!.id,
        updates,
      );

      _currentUser = updatedUser;
      await _storageService.saveUser(_currentUser!);
      notifyListeners();
    } catch (e) {
      throw Exception('프로필 업데이트 실패: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _authService.signOut(),
        _storageService.clearUser(),
      ]);
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      throw Exception('로그아웃 실패: $e');
    }
  }

  Future<void> deleteAccount() async {
    if (_currentUser == null) return;

    try {
      await Future.wait([
        _authService.deleteUser(_currentUser!.id),
        if (_currentUser?.profileImageUrl != null)
          _storageService.deleteProfileImage(_currentUser!.id),
        _storageService.clearUser(),
      ]);
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      throw Exception('계정 삭제 실패: $e');
    }
  }
}
