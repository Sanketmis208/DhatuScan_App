import 'package:flutter/material.dart';

/// A single, app-wide [GlobalKey] for the root [Navigator].
///
/// Registered on [MaterialApp.navigatorKey] so that non-widget code
/// (e.g. the Dio 401 interceptor) can push routes without a [BuildContext].
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
