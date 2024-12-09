class AppConstants {
  // 앱 기본 정보
  static const String appName = '어디서봄';

  // API 기본 설정
  static const String baseApiUrl = 'http://localhost:8000'; // 개발 환경
  static const String apiVersion = 'v1';

  // Google Maps API
  static const String googleMapsApiUrl = 'https://maps.googleapis.com/maps/api';
  static const String googlePlacesApiUrl =
      'https://maps.googleapis.com/maps/api/place';

  // API 엔드포인트
  static const String apiKeyEndpoint = '/api/$apiVersion/maps/google-maps-key';
  static const String authEndpoint = '/api/$apiVersion/auth';
  static const String locationEndpoint = '/api/$apiVersion/location';
  static const String placesEndpoint = '/api/$apiVersion/places';

  // 에러 메시지
  static const String networkError = '네트워크 연결을 확인해주세요';
  static const String locationError = '위치를 찾을 수 없습니다';
  static const String authError = '인증에 실패했습니다';
  static const String serverError = '서버 오류가 발생했습니다';
  static const String unknownError = '알 수 없는 오류가 발생했습니다';

  // 테마 색상
  static const String primaryColor = '0EB4FC';

  // 기타 설정
  static const int defaultPlacesLimit = 5;
  static const int maxRecentLocations = 5;
  static const Duration apiTimeout = Duration(seconds: 10);
}
