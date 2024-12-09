import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import '../models/user.dart';

class StorageService {
  static const String _userKey = 'user_data';
  static const String _profileImagePath = 'profile_images';
  static const String _recentLocationsKey = 'recent_locations';
  static const String _authTokenKey = 'auth_token';
  
  final SharedPreferences _prefs;
  final FirebaseStorage _storage;
  final FlutterSecureStorage _secureStorage;

  StorageService(
    this._prefs, {
    FirebaseStorage? storage,
    FlutterSecureStorage? secureStorage,
  }) : 
    _storage = storage ?? FirebaseStorage.instance,
    _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static Future<StorageService> getInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // 사용자 데이터 관리
  Future<void> saveUser(User user) async {
    final userData = json.encode(user.toJson());
    await _prefs.setString(_userKey, userData);
  }

  Future<User?> getUser() async {
    final userData = _prefs.getString(_userKey);
    if (userData == null) return null;

    try {
      final Map<String, dynamic> jsonData = json.decode(userData);
      return User.fromJson(jsonData);
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }

  // 프로필 이미지 관리
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child('$_profileImagePath/$userId.jpg');
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': userId},
      );

      final uploadTask = ref.putFile(imageFile, metadata);
      final snapshot = await uploadTask.whenComplete(() {});
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('프로필 이미지 업로드 오류: $e');
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    try {
      final ref = _storage.ref().child('$_profileImagePath/$userId.jpg');
      await ref.delete();
    } catch (e) {
      throw Exception('프로필 이미지 삭제 오류: $e');
    }
  }

  // 최근 위치 관리
  Future<void> saveRecentLocation(String address) async {
    final locations = await getRecentLocations();
    if (!locations.contains(address)) {
      locations.insert(0, address);
      if (locations.length > 5) {
        locations.removeLast();
      }
      await _prefs.setStringList(_recentLocationsKey, locations);
    }
  }

  Future<List<String>> getRecentLocations() async {
    return _prefs.getStringList(_recentLocationsKey) ?? [];
  }

  Future<void> clearRecentLocations() async {
    await _prefs.remove(_recentLocationsKey);
  }

  // 인증 토큰 관리
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  Future<void> deleteAuthToken() async {
    await _secureStorage.delete(key: _authTokenKey);
  }

  // 모든 데이터 삭제
  Future<void> clearAll() async {
    await Future.wait([
      clearUser(),
      clearRecentLocations(),
      deleteAuthToken(),
    ]);
  }
}