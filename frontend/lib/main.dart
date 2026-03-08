import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only on supported platforms
  if (!kIsWeb && !Platform.isLinux) {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize persistent settings
  await SettingsService.instance.init();

  runApp(const ProviderScope(child: FabricFlowApp()));
}

class FabricFlowApp extends ConsumerWidget {
  const FabricFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SettingsService.instance.themeNotifier,
      builder: (_, themeMode, __) => MaterialApp(
        title: 'FabricFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
