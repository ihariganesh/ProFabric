import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// API Service for connecting to the FastAPI backend
class ApiService {
  // Base URL for the API - update this for production
  static const String _baseUrl =
      'http://10.0.2.2:8000/api/v1'; // Android emulator localhost
  // static const String _baseUrl = 'http://localhost:8000/api/v1'; // Web/iOS

  late final Dio _dio;
  String? _accessToken;
  String? _refreshToken;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    // Add interceptor for auth and logging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        if (kDebugMode) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print(
              'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        }
        return handler.next(e);
      },
    ));
  }

  // Set tokens after authentication
  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  // Clear tokens on logout
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(endpoint, data: body);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Handle Dio errors
  ApiException _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode ?? 500;
      if (statusCode == 401) {
        return UnauthorizedException('Session expired. Please login again.');
      }
      final data = e.response!.data;
      final message = data is Map
          ? data['detail'] ?? 'An error occurred'
          : 'An error occurred';
      return ApiException(message, statusCode);
    }
    return ApiException('Network error. Please check your connection.', 0);
  }

  // =====================
  // AUTH ENDPOINTS
  // =====================

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });

    // Store tokens
    if (response.containsKey('access_token')) {
      setTokens(
        response['access_token'] as String,
        response['refresh_token'] as String,
      );
    }

    return response;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? businessName,
  }) async {
    return post('/auth/register', {
      'email': email,
      'password': password,
      'name': name,
      'role': role,
      if (phone != null) 'phone': phone,
      if (businessName != null) 'business_name': businessName,
    });
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    return get('/users/me');
  }

  // =====================
  // WORKFLOW ENDPOINTS
  // =====================

  /// Get role-specific dashboard orders
  Future<List<dynamic>> getDashboardOrders() async {
    final response = await get('/workflow/dashboard/my-orders');
    return response['data'] as List<dynamic>? ?? [];
  }

  /// Update order status
  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String newStatus,
      {String? notes}) async {
    return post('/workflow/orders/$orderId/update-status', {
      'new_status': newStatus,
      if (notes != null) 'notes': notes,
    });
  }

  /// Get available transitions for an order
  Future<List<dynamic>> getAvailableTransitions(int orderId) async {
    final response =
        await get('/workflow/orders/$orderId/available-transitions');
    return response['data'] as List<dynamic>? ?? [];
  }

  /// Get order timeline
  Future<List<dynamic>> getOrderTimeline(int orderId) async {
    final response = await get('/workflow/orders/$orderId/timeline');
    return response['data'] as List<dynamic>? ?? [];
  }

  /// Get order cascade (supply chain view)
  Future<Map<String, dynamic>> getOrderCascade(int orderId) async {
    return get('/workflow/orders/$orderId/cascade');
  }

  // =====================
  // TEXTILE ORCHESTRATOR ENDPOINTS
  // =====================

  /// Accept an order as textile orchestrator
  Future<Map<String, dynamic>> textileAcceptOrder(
      int orderId, double proposedCost, int estimatedDays) async {
    return post('/workflow/textile/orders/$orderId/accept', {
      'proposed_cost': proposedCost,
      'estimated_days': estimatedDays,
    });
  }

  /// Assign fabric seller to order
  Future<Map<String, dynamic>> assignFabricSeller(
      int orderId, int vendorId, double cost,
      {Map<String, dynamic>? details}) async {
    return post('/workflow/textile/orders/$orderId/assign-fabric-seller', {
      'vendor_id': vendorId,
      'cost': cost,
      if (details != null) 'details': details,
    });
  }

  /// Assign printing unit to order
  Future<Map<String, dynamic>> assignPrintingUnit(
      int orderId, int vendorId, double cost,
      {Map<String, dynamic>? details}) async {
    return post('/workflow/textile/orders/$orderId/assign-printing-unit', {
      'vendor_id': vendorId,
      'cost': cost,
      if (details != null) 'details': details,
    });
  }

  /// Assign stitching unit to order
  Future<Map<String, dynamic>> assignStitchingUnit(
      int orderId, int vendorId, double cost,
      {Map<String, dynamic>? details}) async {
    return post('/workflow/textile/orders/$orderId/assign-stitching-unit', {
      'vendor_id': vendorId,
      'cost': cost,
      if (details != null) 'details': details,
    });
  }

  // =====================
  // ORDER ENDPOINTS
  // =====================

  /// Create a new order
  Future<Map<String, dynamic>> createOrder({
    required String fabricType,
    required int quantity,
    String? designPrompt,
    int? threadCount,
    int? gsm,
  }) async {
    return post('/orders', {
      'fabric_type': fabricType,
      'quantity_meters': quantity,
      if (designPrompt != null) 'design_prompt': designPrompt,
      if (threadCount != null) 'thread_count': threadCount,
      if (gsm != null) 'gsm': gsm,
    });
  }

  /// Get order details
  Future<Map<String, dynamic>> getOrder(int orderId) async {
    return get('/orders/$orderId');
  }

  /// Get all orders for current user
  Future<List<dynamic>> getMyOrders() async {
    final response = await get('/orders');
    return response['data'] as List<dynamic>? ?? [];
  }

  // =====================
  // AI DESIGN ENDPOINTS
  // =====================

  /// Generate AI design
  Future<Map<String, dynamic>> generateDesign(String prompt,
      {String? style}) async {
    return post('/ai/generate-design', {
      'prompt': prompt,
      if (style != null) 'style': style,
    });
  }

  // =====================
  // NOTIFICATION ENDPOINTS
  // =====================

  /// Get notifications
  Future<List<dynamic>> getNotifications({bool unreadOnly = false}) async {
    final endpoint =
        unreadOnly ? '/notifications?unread_only=true' : '/notifications';
    final response = await get(endpoint);
    return response['data'] as List<dynamic>? ?? [];
  }

  /// Mark notification as read
  Future<void> markNotificationRead(int notificationId) async {
    await post('/notifications/$notificationId/read', {});
  }

  // =====================
  // PRODUCTS/MARKETPLACE ENDPOINTS
  // =====================

  /// Get marketplace products
  Future<List<dynamic>> getProducts({String? category, String? search}) async {
    var endpoint = '/products';
    final params = <String>[];
    if (category != null) params.add('category=$category');
    if (search != null) params.add('search=$search');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final response = await get(endpoint);
    return response['data'] as List<dynamic>? ?? [];
  }

  /// Get vendor's products
  Future<List<dynamic>> getMyProducts() async {
    final response = await get('/products/my');
    return response['data'] as List<dynamic>? ?? [];
  }

  /// Add new product
  Future<Map<String, dynamic>> addProduct(
      Map<String, dynamic> productData) async {
    return post('/products', productData);
  }

  // =====================
  // VENDORS ENDPOINTS
  // =====================

  /// Get vendors by role
  Future<List<dynamic>> getVendorsByRole(String role) async {
    final response = await get('/users/vendors?role=$role');
    return response['data'] as List<dynamic>? ?? [];
  }

  // =====================
  // PAYMENT ENDPOINTS
  // =====================

  /// Create payment
  Future<Map<String, dynamic>> createPayment({
    required int orderId,
    required double amount,
    required String milestone,
  }) async {
    return post('/payments', {
      'order_id': orderId,
      'amount': amount,
      'milestone': milestone,
    });
  }

  /// Get payment status
  Future<Map<String, dynamic>> getPaymentStatus(int paymentId) async {
    return get('/payments/$paymentId');
  }
}

// Custom Exceptions
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
