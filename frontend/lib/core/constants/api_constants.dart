class ApiConstants {
  // Base URL - Change for production
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // WebSocket URL
  static const String wsBaseUrl = 'ws://localhost:8000/api/v1';

  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';

  static const String orders = '/orders';
  static const String myOrders = '/orders/my-orders';

  static const String generateDesign = '/ai/generate-design';
  static const String calculateBOM = '/ai/calculate-bom';

  static const String findVendors = '/optimize/find-vendors';
  static const String optimizeRoute = '/optimize/route';

  static const String tracking = '/tracking/order';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
