import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/navigation/navigator_key.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

/// Root widget.  Registers [navigatorKey] so that the Dio 401 interceptor
/// can redirect to `/landing` without a [BuildContext].
///
/// Theme, fonts, and full route table will be fleshed out in task 5.1.
class DhatuScanApp extends StatelessWidget {
  const DhatuScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // AssessmentProvider and HistoryProvider added in task 5.1
      ],
      child: MaterialApp(
        title: 'DhatuScan',
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        // Full theme and route table will be populated in task 5.1.
        routes: {
          '/landing': (context) => const Scaffold(
                body: Center(child: Text('Landing')),
              ),
        },
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
