import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/location_provider.dart';
import 'providers/meeting_provider.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: FirebaseConfig.currentPlatform,
  );

  // 서비스 인스턴스 생성
  final authService = AuthService();
  final locationService = LocationService();
  final storageService = await StorageService.getInstance();
  final apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(
            locationService: locationService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => MeetingProvider(
            locationService: locationService,
            apiService: apiService,
          ),
        ),
      ],
      child: const UdsbomApp(),
    ),
  );
}