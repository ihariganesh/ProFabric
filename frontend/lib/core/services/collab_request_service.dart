import 'dart:async';

/// Represents a collaboration request from buyer → textile vendor.
class CollabRequest {
  final String id;
  final String vendorName;
  final String vendorLocation;
  final String designId;
  final DateTime createdAt;
  CollabRequestStatus status;
  DateTime? respondedAt;

  // Extra details set when buyer sends request
  String buyerName;
  String fabricType;
  int quantityMeters;
  String deadline;

  // Details set when textile accepts
  int? agreedPrice;
  String? agreedTimeline;

  // Production progress (0.0 – 1.0)
  double productionProgress;
  String productionStage;

  CollabRequest({
    required this.id,
    required this.vendorName,
    required this.vendorLocation,
    required this.designId,
    required this.createdAt,
    this.status = CollabRequestStatus.pending,
    this.respondedAt,
    this.buyerName = 'Buyer',
    this.fabricType = 'Fabric',
    this.quantityMeters = 0,
    this.deadline = 'TBD',
    this.agreedPrice,
    this.agreedTimeline,
    this.productionProgress = 0.0,
    this.productionStage = 'Pending',
  });
}

enum CollabRequestStatus { pending, accepted, rejected, inProduction, readyToShip }

/// An in-app notification entry.
class AppNotification {
  final String id;
  final String title;
  final String subtitle;
  final String icon; // icon name key
  final DateTime createdAt;
  final String category; // orders, requests, production, logistics, payments
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.createdAt,
    this.category = 'requests',
    this.isRead = false,
  });
}

/// Singleton service that manages collab requests and notifications locally.
class CollabRequestService {
  CollabRequestService._();
  static final CollabRequestService instance = CollabRequestService._();

  final List<CollabRequest> _requests = [];
  final List<AppNotification> _notifications = [];

  // Stream controllers for reactive UI updates
  final _requestController = StreamController<List<CollabRequest>>.broadcast();
  final _notificationController =
      StreamController<List<AppNotification>>.broadcast();

  Stream<List<CollabRequest>> get requestStream => _requestController.stream;
  Stream<List<AppNotification>> get notificationStream =>
      _notificationController.stream;

  List<CollabRequest> get requests => List.unmodifiable(_requests);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Buyer sends a collab request to a vendor.
  CollabRequest sendRequest({
    required String vendorName,
    required String vendorLocation,
    String designId = '',
    String buyerName = 'Buyer',
    String fabricType = 'Fabric',
    int quantityMeters = 0,
    String deadline = 'TBD',
  }) {
    final id = 'CR-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final request = CollabRequest(
      id: id,
      vendorName: vendorName,
      vendorLocation: vendorLocation,
      designId: designId,
      createdAt: DateTime.now(),
      buyerName: buyerName,
      fabricType: fabricType,
      quantityMeters: quantityMeters,
      deadline: deadline,
    );
    _requests.insert(0, request);
    _requestController.add(_requests);

    _addNotification(
      title: 'Request Sent to $vendorName',
      subtitle: 'Your collaboration request has been sent. Waiting for their response.',
      icon: 'send',
      category: 'requests',
    );

    return request;
  }

  /// Textile vendor accepts the request → moves to In Production
  void acceptRequest(String requestId, {String? timeline, int? price}) {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      final request = _requests[idx];
      request.status = CollabRequestStatus.inProduction;
      request.respondedAt = DateTime.now();
      request.agreedPrice = price;
      request.agreedTimeline = timeline;
      request.productionProgress = 0.05;
      request.productionStage = 'Order Accepted – Starting Production';
      _requestController.add(_requests);

      _addNotification(
        title: '${request.vendorName} Accepted! 🎉',
        subtitle: 'Your order is now in production. Timeline: ${timeline ?? "TBD"}.',
        icon: 'accepted',
        category: 'requests',
      );

      // Start automatic backend ML progression simulation
      _startPredictiveTracking(request);
    }
  }

  void _startPredictiveTracking(CollabRequest request) {
    // Simulates the predictive ML model updating progress
    Timer.periodic(const Duration(seconds: 4), (timer) {
      // Stop tracking if already completed manually
      if (request.status != CollabRequestStatus.inProduction) {
        timer.cancel();
        return;
      }

      // Add random progress incrementally imitating an ML prediction update
      double step = (0.05 + (DateTime.now().millisecond % 5) / 100.0);
      double nextProgress = request.productionProgress + step;
      
      if (nextProgress > 1.0) nextProgress = 1.0;

      String stage = 'In Production';
      if (nextProgress >= 0.25 && nextProgress < 0.50) stage = 'Fabric Sourcing';
      if (nextProgress >= 0.50 && nextProgress < 0.75) stage = 'Printing';
      if (nextProgress >= 0.75 && nextProgress < 1.00) stage = 'Stitching';
      if (nextProgress >= 1.00) stage = 'Quality Check Pass';

      if (nextProgress >= 1.00) {
        markReadyToShip(request.id);
        timer.cancel();
      } else {
        updateProgress(request.id, nextProgress, stage);
      }
    });
  }

  /// Textile vendor rejects the request
  void rejectRequest(String requestId) {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      final request = _requests[idx];
      request.status = CollabRequestStatus.rejected;
      request.respondedAt = DateTime.now();
      _requestController.add(_requests);

      _addNotification(
        title: '${request.vendorName} Declined',
        subtitle: 'They are currently at full capacity.',
        icon: 'declined',
        category: 'requests',
      );
    }
  }

  /// Update production progress (called by textile when they update stages)
  void updateProgress(String requestId, double progress, String stage) {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _requests[idx].productionProgress = progress;
      _requests[idx].productionStage = stage;
      if (progress >= 1.0) {
        _requests[idx].status = CollabRequestStatus.readyToShip;
      }
      _requestController.add(_requests);
    }
  }

  /// Mark order ready to ship
  void markReadyToShip(String requestId) {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _requests[idx].status = CollabRequestStatus.readyToShip;
      _requests[idx].productionProgress = 1.0;
      _requests[idx].productionStage = 'Ready for Shipment';
      _requestController.add(_requests);

      _addNotification(
        title: 'Order Ready to Ship! 📦',
        subtitle: '${_requests[idx].vendorName} has completed your order.',
        icon: 'ship',
        category: 'logistics',
      );
    }
  }

  // Helpers
  List<CollabRequest> get pendingRequests =>
      _requests.where((r) => r.status == CollabRequestStatus.pending).toList();
  List<CollabRequest> get inProductionRequests =>
      _requests.where((r) => r.status == CollabRequestStatus.inProduction).toList();
  List<CollabRequest> get readyToShipRequests =>
      _requests.where((r) => r.status == CollabRequestStatus.readyToShip).toList();

  void _addNotification({
    required String title,
    required String subtitle,
    required String icon,
    required String category,
  }) {
    final notif = AppNotification(
      id: 'N-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      icon: icon,
      createdAt: DateTime.now(),
      category: category,
    );
    _notifications.insert(0, notif);
    _notificationController.add(_notifications);
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    _notificationController.add(_notifications);
  }

  void markRead(String id) {
    final n = _notifications.firstWhere((n) => n.id == id,
        orElse: () => _notifications.first);
    n.isRead = true;
    _notificationController.add(_notifications);
  }

  /// Seed some sample notifications so the screen isn't empty on first open.
  void seedSampleNotifications() {
    // No sample data – notifications will populate from real vendor responses.
  }

  void dispose() {
    _requestController.close();
    _notificationController.close();
  }
}
