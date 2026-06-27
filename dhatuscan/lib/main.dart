import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/local_storage_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise SharedPreferences wrapper before any service accesses it.
  await LocalStorageService.init();

  // Initialise Firebase (required for phone OTP auth).
  await Firebase.initializeApp();

  runApp(const DhatuScanApp());
}
