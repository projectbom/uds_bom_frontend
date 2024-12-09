import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage;
  final ApiService _apiService;
  final GoogleSignIn _googleSignIn;
  late final StorageService _storageService; // late 키워드 사용

  AuthService({
    FlutterSecureStorage? secureStorage,
    ApiService? apiService,
    StorageService? storageService,
    GoogleSignIn? googleSignIn,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _apiService = apiService ?? ApiService(),
        _googleSignIn = googleSignIn ?? GoogleSignIn() {
    _initializeStorageService(); // 생성자에서 초기화 함수 호출
  }

  Future<void> _initializeStorageService() async {
    final prefs = await SharedPreferences.getInstance();
    _storageService = StorageService(prefs);
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) return null;

      final response = await _apiService.get('/auth/me');
      final user = User.fromJson(response['user']);
      await _storageService.saveUser(user);
      return user;
    } catch (e) {
      return _storageService.getUser();
    }
  }

  Future<User> signInWithEmail(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      );

      final user = User.fromJson(response['user']);
      await Future.wait([
        _secureStorage.write(key: 'auth_token', value: response['token']),
        _storageService.saveUser(user),
      ]);

      return user;
    } catch (e) {
      throw Exception('이메일 로그인 실패: $e');
    }
  }

  Future<User> signInWithKakao() async {
    try {
      if (await kakao.isKakaoTalkInstalled()) {
        await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      final kakaoUser = await kakao.UserApi.instance.me();

      final response = await _apiService.post(
        '/auth/kakao',
        body: {
          'id': kakaoUser.id.toString(),
          'name': kakaoUser.kakaoAccount?.profile?.nickname,
          'email': kakaoUser.kakaoAccount?.email,
          'profileImageUrl': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        },
      );

      final user = User.fromJson(response['user']);
      await Future.wait([
        _secureStorage.write(key: 'auth_token', value: response['token']),
        _storageService.saveUser(user),
      ]);

      return user;
    } catch (e) {
      throw Exception('카카오 로그인 실패: $e');
    }
  }

  Future<User> signInWithNaver() async {
    try {
      final result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.loggedIn) {
        final account = await FlutterNaverLogin.currentAccount();

        final response = await _apiService.post(
          '/auth/naver',
          body: {
            'id': account.id,
            'name': account.name,
            'email': account.email,
            'profileImageUrl': account.profileImage,
          },
        );

        final user = User.fromJson(response['user']);
        await Future.wait([
          _secureStorage.write(key: 'auth_token', value: response['token']),
          _storageService.saveUser(user),
        ]);

        return user;
      }

      throw Exception('네이버 로그인이 취소되었습니다');
    } catch (e) {
      throw Exception('네이버 로그인 실패: $e');
    }
  }

  Future<User> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('구글 로그인이 취소되었습니다');

      final googleAuth = await googleUser.authentication;

      final response = await _apiService.post(
        '/auth/google',
        body: {
          'id': googleUser.id,
          'name': googleUser.displayName,
          'email': googleUser.email,
          'profileImageUrl': googleUser.photoUrl,
          'idToken': googleAuth.idToken,
        },
      );

      final user = User.fromJson(response['user']);
      await Future.wait([
        _secureStorage.write(key: 'auth_token', value: response['token']),
        _storageService.saveUser(user),
      ]);

      return user;
    } catch (e) {
      throw Exception('구글 로그인 실패: $e');
    }
  }

  Future<User> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.patch(
        '/users/$userId',
        body: updates,
      );
      final user = User.fromJson(response['user']);
      await _storageService.saveUser(user);
      return user;
    } catch (e) {
      throw Exception('사용자 정보 업데이트 실패: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete('/users/$userId');
      await Future.wait([
        _secureStorage.delete(key: 'auth_token'),
        _storageService.clearUser(),
      ]);
    } catch (e) {
      throw Exception('계정 삭제 실패: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: 'auth_token'),
        _storageService.clearUser(),
        FlutterNaverLogin.logOut(),
        _googleSignIn.signOut(),
        kakao.UserApi.instance.logout(),
      ]);
    } catch (e) {
      throw Exception('로그아웃 실패: $e');
    }
  }
}
