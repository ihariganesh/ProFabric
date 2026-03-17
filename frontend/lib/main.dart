import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/services/settings_service.dart';
import 'core/services/mcp_bridge.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize MCP Bridge
  McpBridge.instance.start(apiUrl: "http://127.0.0.1:8000"); // 10.0.2.2 on emulator if needed

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
