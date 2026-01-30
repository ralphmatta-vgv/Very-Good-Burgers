import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/app_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';
import 'utils/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show a safe error widget instead of crashing when a widget throws
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('Something went wrong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('${details.exception}', style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  runZonedGuarded(() async {
    try {
      await StorageService.init();
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
            ChangeNotifierProvider(create: (_) => CartProvider()),
            ChangeNotifierProvider(create: (_) => UserProvider()),
          ],
          child: const VeryGoodBurgersApp(),
        ),
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Startup error: $e');
        debugPrint(stack.toString());
      }
      runApp(_FallbackApp(error: e.toString(), stack: stack.toString()));
    }
  }, (error, stack) {
    if (kDebugMode) {
      debugPrint('Zone error: $error');
      debugPrint(stack.toString());
    }
    runApp(_FallbackApp(error: error.toString(), stack: stack.toString()));
  });
}

/// Minimal app shown when startup fails so the app doesn't exit and we can see the error.
class _FallbackApp extends StatelessWidget {
  const _FallbackApp({required this.error, required this.stack});

  final String error;
  final String stack;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Startup error', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                Text(stack, style: const TextStyle(fontSize: 10), maxLines: 20, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
