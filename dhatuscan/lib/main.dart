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
    await Firebase.initializeApp();
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
