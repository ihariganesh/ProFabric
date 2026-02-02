import 'dart:async';
import '../../../core/services/api_service.dart';

/// Service for logistics and shipment tracking
class LogisticsService {
  final ApiService _api;

  LogisticsService({ApiService? api}) : _api = api ?? ApiService();

  /// Get all shipments for current logistics provider
  Future<ShipmentListResult> getShipments({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      String endpoint = '/tracking/shipments?limit=$limit&offset=$offset';
      if (status != null) {
        endpoint += '&status=$status';
      }
      final response = await _api.get(endpoint);

      return ShipmentListResult(
        shipments: (response['shipments'] as List? ?? [])
            .map((s) => ShipmentData.fromJson(s))
            .toList(),
        total: response['total'] ?? 0,
      );
    } catch (e) {
      throw LogisticsException(message: e.toString());
    }
  }

  /// Get shipment details by ID
  Future<ShipmentData> getShipment(int shipmentId) async {
    try {
      final response = await _api.get('/tracking/shipments/$shipmentId');
      return ShipmentData.fromJson(response);
    } catch (e) {
      throw LogisticsException(message: e.toString());
    }
  }

  /// Create a new shipment
  Future<CreateShipmentResult> createShipment({
    int? subOrderId,
    required String pickupLocation,
    Map<String, double>? pickupCoordinates,
    required String dropLocation,
    Map<String, double>? dropCoordinates,
    Map<String, dynamic>? vehicleInfo,
    DateTime? estimatedPickup,
    DateTime? estimatedDelivery,
  }) async {
    try {
      final response = await _api.post('/tracking/shipments', {
        'sub_order_id': subOrderId,
        'pickup_location': pickupLocation,
        'pickup_coordinates': pickupCoordinates,
        'drop_location': dropLocation,
        'drop_coordinates': dropCoordinates,
        'vehicle_info': vehicleInfo,
        'estimated_pickup': estimatedPickup?.toIso8601String(),
        'estimated_delivery': estimatedDelivery?.toIso8601String(),
      });

      return CreateShipmentResult(
        shipmentId: response['shipment_id'],
        trackingNumber: response['tracking_number'],
      );
    } catch (e) {
      throw LogisticsException(message: e.toString());
    }
  }

  /// Update shipment status
  Future<void> updateShipmentStatus({
    required int shipmentId,
    required String status,
    String? deliveryProofUrl,
    GpsCheckpoint? checkpoint,
  }) async {
    try {
      await _api.post('/tracking/shipments/$shipmentId/status', {
        'status': status,
        'delivery_proof_url': deliveryProofUrl,
        'checkpoint': checkpoint?.toJson(),
      });
    } catch (e) {
      throw LogisticsException(message: e.toString());
    }
  }

  /// Add GPS checkpoint to shipment
  Future<void> addCheckpoint({
    required int shipmentId,
    required double lat,
    required double lng,
    String? locationName,
    String? notes,
  }) async {
    try {
      await _api.post('/tracking/shipments/$shipmentId/checkpoint', {
        'lat': lat,
        'lng': lng,
        'location_name': locationName,
        'notes': notes,
      });
    } catch (e) {
      throw LogisticsException(message: e.toString());
    }
  }

  /// Get all shipments for an order
  Future<OrderShipmentsResult> getOrderShipments(int orderId) async {
    try {
      final response = await _api.get('/tracking/order/$orderId');
      return OrderShipmentsResult(
        orderId: response['order_id'],
        shipments: (response['shipments'] as List? ?? [])
            .map((s) => ShipmentData.fromJson(s))
            .toList(),
      );
    } catch (e) {
      throw LogisticsException(message: e.toString());
    }
  }

  /// Get optimized route between two points
  Future<RouteOptimizationResult> getOptimizedRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final endpoint = '/tracking/route/optimize'
          '?origin_lat=$originLat'
          '&origin_lng=$originLng'
          '&dest_lat=$destLat'
          '&dest_lng=$destLng';
      final response = await _api.get(endpoint);
      return RouteOptimizationResult.fromJson(response);
    } catch (e) {
      throw LogisticsException(message: e.toString());
    }
  }
}

/// Shipment data model
class ShipmentData {
  final int shipmentId;
  final String trackingNumber;
  final int? subOrderId;
  final int? logisticsProviderId;
  final String pickupLocation;
  final Map<String, dynamic>? pickupCoordinates;
  final String dropLocation;
  final Map<String, dynamic>? dropCoordinates;
  final String? currentStatus;
  final Map<String, dynamic>? vehicleInfo;
  final DateTime? estimatedPickup;
  final DateTime? actualPickup;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final List<GpsCheckpoint> gpsCheckpoints;
  final String? deliveryProofUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShipmentData({
    required this.shipmentId,
    required this.trackingNumber,
    this.subOrderId,
    this.logisticsProviderId,
    required this.pickupLocation,
    this.pickupCoordinates,
    required this.dropLocation,
    this.dropCoordinates,
    this.currentStatus,
    this.vehicleInfo,
    this.estimatedPickup,
    this.actualPickup,
    this.estimatedDelivery,
    this.actualDelivery,
    this.gpsCheckpoints = const [],
    this.deliveryProofUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ShipmentData.fromJson(Map<String, dynamic> json) {
    return ShipmentData(
      shipmentId: json['shipment_id'] ?? 0,
      trackingNumber: json['tracking_number'] ?? '',
      subOrderId: json['sub_order_id'],
      logisticsProviderId: json['logistics_provider_id'],
      pickupLocation: json['pickup_location'] ?? '',
      pickupCoordinates: json['pickup_coordinates'],
      dropLocation: json['drop_location'] ?? '',
      dropCoordinates: json['drop_coordinates'],
      currentStatus: json['current_status'],
      vehicleInfo: json['vehicle_info'],
      estimatedPickup: json['estimated_pickup'] != null
          ? DateTime.tryParse(json['estimated_pickup'])
          : null,
      actualPickup: json['actual_pickup'] != null
          ? DateTime.tryParse(json['actual_pickup'])
          : null,
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.tryParse(json['estimated_delivery'])
          : null,
      actualDelivery: json['actual_delivery'] != null
          ? DateTime.tryParse(json['actual_delivery'])
          : null,
      gpsCheckpoints: (json['gps_checkpoints'] as List? ?? [])
          .map((c) => GpsCheckpoint.fromJson(c))
          .toList(),
      deliveryProofUrl: json['delivery_proof_url'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Get progress percentage based on status
  double get progressPercentage {
    switch (currentStatus) {
      case 'Pending_Pickup':
        return 0.1;
      case 'Picked_Up':
        return 0.25;
      case 'In_Transit':
        return 0.5;
      case 'At_Checkpoint':
        return 0.65;
      case 'Out_For_Delivery':
        return 0.85;
      case 'Delivered':
        return 1.0;
      default:
        return 0.0;
    }
  }

  /// Get human-readable status
  String get statusDisplay {
    return currentStatus?.replaceAll('_', ' ') ?? 'Unknown';
  }
}

/// GPS checkpoint data
class GpsCheckpoint {
  final double lat;
  final double lng;
  final String? locationName;
  final DateTime? timestamp;
  final String? notes;
  final String? status;

  GpsCheckpoint({
    required this.lat,
    required this.lng,
    this.locationName,
    this.timestamp,
    this.notes,
    this.status,
  });

  factory GpsCheckpoint.fromJson(Map<String, dynamic> json) {
    return GpsCheckpoint(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      locationName: json['location_name'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'])
          : null,
      notes: json['notes'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'location_name': locationName,
      'notes': notes,
    };
  }
}

/// Shipment list result
class ShipmentListResult {
  final List<ShipmentData> shipments;
  final int total;

  ShipmentListResult({
    required this.shipments,
    required this.total,
  });
}

/// Create shipment result
class CreateShipmentResult {
  final int shipmentId;
  final String trackingNumber;

  CreateShipmentResult({
    required this.shipmentId,
    required this.trackingNumber,
  });
}

/// Order shipments result
class OrderShipmentsResult {
  final int orderId;
  final List<ShipmentData> shipments;

  OrderShipmentsResult({
    required this.orderId,
    required this.shipments,
  });
}

/// Route optimization result
class RouteOptimizationResult {
  final double distanceKm;
  final double estimatedDurationHours;
  final String? routePolyline;
  final List<RouteWaypoint> waypoints;
  final double fuelEstimateLiters;
  final String? trafficConditions;

  RouteOptimizationResult({
    required this.distanceKm,
    required this.estimatedDurationHours,
    this.routePolyline,
    required this.waypoints,
    required this.fuelEstimateLiters,
    this.trafficConditions,
  });

  factory RouteOptimizationResult.fromJson(Map<String, dynamic> json) {
    return RouteOptimizationResult(
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      estimatedDurationHours: (json['estimated_duration_hours'] as num?)?.toDouble() ?? 0.0,
      routePolyline: json['route_polyline'],
      waypoints: (json['waypoints'] as List? ?? [])
          .map((w) => RouteWaypoint.fromJson(w))
          .toList(),
      fuelEstimateLiters: (json['fuel_estimate_liters'] as num?)?.toDouble() ?? 0.0,
      trafficConditions: json['traffic_conditions'],
    );
  }
}

/// Route waypoint
class RouteWaypoint {
  final double lat;
  final double lng;
  final String name;

  RouteWaypoint({
    required this.lat,
    required this.lng,
    required this.name,
  });

  factory RouteWaypoint.fromJson(Map<String, dynamic> json) {
    return RouteWaypoint(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      name: json['name'] ?? '',
    );
  }
}

/// Logistics exception
class LogisticsException implements Exception {
  final String message;
  final int? code;

  LogisticsException({required this.message, this.code});

  @override
  String toString() => 'LogisticsException: $message';
}
