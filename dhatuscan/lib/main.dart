import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/assessment_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/history_provider.dart';
import 'providers/user_provider.dart';
import 'services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise local storage before anything else touches it.
  await LocalStorageService.init();

  // Initialise Firebase (required for phone OTP auth).
  try {
    FirebaseOptions? options;
    try {
      if (Platform.isIOS) {
        options = const FirebaseOptions(
          apiKey: 'AIzaSyBSL4p_MHQnT4-45TjUswQ8whdWT2kxidk',
          appId: '1:553622699540:ios:4603ab4c5b82ebbfa63101',
          messagingSenderId: '553622699540',
          projectId: 'dhatuscan-d63ab',
          storageBucket: 'dhatuscan-d63ab.firebasestorage.app',
          iosBundleId: 'com.dhatuscan.dhatuscan',
        );
      } else if (Platform.isAndroid) {
        options = const FirebaseOptions(
          apiKey: 'AIzaSyDfEKsf0oonFintAn2jtkK5GkbUkkIB2tI',
          appId: '1:553622699540:android:114ce908a00fc492a63101',
          messagingSenderId: '553622699540',
          projectId: 'dhatuscan-d63ab',
          storageBucket: 'dhatuscan-d63ab.firebasestorage.app',
        );
      }
    } catch (_) {
      // Fallback for non-mobile platforms (e.g., test framework environment)
    }
    await Firebase.initializeApp(options: options);
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const DhatuScanApp(),
    ),
  );
}
