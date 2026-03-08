import 'dart:async';
import 'dart:math';

/// Represents a collaboration request from buyer → textile vendor.
class CollabRequest {
  final String id;
  final String vendorName;
  final String vendorLocation;
  final String designId;
  final DateTime createdAt;
  CollabRequestStatus status;
  DateTime? respondedAt;

  CollabRequest({
    required this.id,
    required this.vendorName,
    required this.vendorLocation,
    required this.designId,
    required this.createdAt,
    this.status = CollabRequestStatus.pending,
    this.respondedAt,
  });
}

enum CollabRequestStatus { pending, accepted, rejected }

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
  /// Returns the created request.
  /// Simulates vendor response after a short delay.
  CollabRequest sendRequest({
    required String vendorName,
    required String vendorLocation,
    String designId = '',
  }) {
    final id = 'CR-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final request = CollabRequest(
      id: id,
      vendorName: vendorName,
      vendorLocation: vendorLocation,
      designId: designId,
      createdAt: DateTime.now(),
    );
    _requests.insert(0, request);
    _requestController.add(_requests);

    // Add "request sent" notification
    _addNotification(
      title: 'Request Sent to $vendorName',
      subtitle:
          'Your collaboration request has been sent. Waiting for their response.',
      icon: 'send',
      category: 'requests',
    );

    // Simulate vendor accepting after 5-12 seconds
    final delay = 5 + Random().nextInt(8);
    Future.delayed(Duration(seconds: delay), () {
      _simulateVendorResponse(request);
    });

    return request;
  }

  void _simulateVendorResponse(CollabRequest request) {
    // 85% chance of acceptance
    final accepted = Random().nextDouble() < 0.85;
    request.status =
        accepted ? CollabRequestStatus.accepted : CollabRequestStatus.rejected;
    request.respondedAt = DateTime.now();
    _requestController.add(_requests);

    if (accepted) {
      _addNotification(
        title: '${request.vendorName} Accepted! 🎉',
        subtitle:
            'Your collaboration request was accepted. They will review your design and share a production timeline.',
        icon: 'accepted',
        category: 'requests',
      );
    } else {
      _addNotification(
        title: '${request.vendorName} Declined',
        subtitle:
            'They are currently at full capacity. Try another vendor from the matching list.',
        icon: 'declined',
        category: 'requests',
      );
    }
  }

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
