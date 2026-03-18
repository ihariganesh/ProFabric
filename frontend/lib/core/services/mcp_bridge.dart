import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class McpBridge {
  static final McpBridge instance = McpBridge._internal();
  McpBridge._internal();

  String currentScreen = "unknown";
  Map<String, dynamic> data = {};
  List<String> errors = [];
  Map<String, Function(String)> actionHandlers = {};
  List<String> get widgets => actionHandlers.keys.toList();

  Timer? _pollTimer;
  // Default bounds for Android/Desktop etc. User can override to 10.0.2.2 on Android emulator
  String baseUrl = 'http://10.0.2.2:8000'; // Default for Android Emulator

  void registerScreen(String screenName) {
    currentScreen = screenName;
    actionHandlers.clear();
    data.clear();
    errors.clear();
    _pushState();
  }

  void registerWidget(String widgetId, Function(String) onAction) {
    actionHandlers[widgetId] = onAction;
  }

  void unregisterWidget(String widgetId) {
    actionHandlers.remove(widgetId);
  }

  void updateData(String key, dynamic value) {
    data[key] = value;
    _pushState();
  }

  void addError(String errorMsg) {
    if (!errors.contains(errorMsg)) {
      errors.add(errorMsg);
      _pushState();
    }
  }

  void start({String? apiUrl}) {
    if (apiUrl != null) {
      baseUrl = apiUrl;
    }
    _pushState();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _pollAction();
    });
  }

  Future<void> _pushState() async {
    try {
      final state = {
        "screen": currentScreen,
        "widgets": widgets,
        "data": data,
        "errors": errors,
      };
      
      final url = Uri.parse('$baseUrl/app/state');
      debugPrint('MCP Bridge pushing to: $url');
      final r = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(state),
      );
      debugPrint('MCP Bridge push Response: ${r.statusCode}');
    } catch (e) {
      debugPrint('MCP Bridge Error: $e');
      // Ignored for resilience when MCP server is not running
    }
  }

  Future<void> _pollAction() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/app/action'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['action'] != null) {
          final action = responseData['action'];
          final target = action['target'];
          final value = action['value'] ?? '';
          if (actionHandlers.containsKey(target)) {
            debugPrint("MCP Executing Action on Widget: $target");
            actionHandlers[target]!(value);
            _pushState();
          }
        }
      }
    } catch (e) {
      // Ignored for resilience
    }
  }
}
