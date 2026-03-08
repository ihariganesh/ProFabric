import 'package:flutter/material.dart';

/// Order model for buyer orders
class BuyerOrder {
  final String id;
  final String productName;
  final String fabricType;
  final String status;
  final Color statusColor;
  final double progress;
  final String quantity;
  final String eta;
  final double budget;
  final String? sampleImageUrl;
  final String? aiDesignUrl;
  final String vendorName;
  final String vendorId;
  final DateTime createdAt;
  final DateTime deadline;
  final List<OrderUpdate> updates;
  final bool isReported;

  BuyerOrder({
    required this.id,
    required this.productName,
    required this.fabricType,
    required this.status,
    required this.statusColor,
    required this.progress,
    required this.quantity,
    required this.eta,
    required this.budget,
    this.sampleImageUrl,
    this.aiDesignUrl,
    required this.vendorName,
    required this.vendorId,
    required this.createdAt,
    required this.deadline,
    this.updates = const [],
    this.isReported = false,
  });
}

/// Order progress update from vendor
class OrderUpdate {
  final String id;
  final String message;
  final String? imageUrl;
  final DateTime timestamp;
  final String stage;
  final double progressPercent;

  OrderUpdate({
    required this.id,
    required this.message,
    this.imageUrl,
    required this.timestamp,
    required this.stage,
    required this.progressPercent,
  });
}

/// Vendor/Textile manufacturer model
class TextileVendor {
  final String id;
  final String name;
  final String location;
  final double rating;
  final int completedOrders;
  final int trustScore;
  final int speedScore;
  final int qualityScore;
  final String specialization;
  final String? avatarUrl;
  final bool isVerified;
  final double pricePerMeter;
  final String estimatedDelivery;
  final List<String> tags;

  TextileVendor({
    required this.id,
    required this.name,
    required this.location,
    required this.rating,
    required this.completedOrders,
    required this.trustScore,
    required this.speedScore,
    required this.qualityScore,
    required this.specialization,
    this.avatarUrl,
    this.isVerified = false,
    required this.pricePerMeter,
    required this.estimatedDelivery,
    this.tags = const [],
  });
}

/// Marketplace product model
class MarketplaceProduct {
  final String id;
  final String title;
  final String description;
  final double price;
  final String unit;
  final String sellerName;
  final String sellerId;
  final String category;
  final List<String> imageUrls;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DateTime postedAt;

  MarketplaceProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.unit,
    required this.sellerName,
    required this.sellerId,
    required this.category,
    required this.imageUrls,
    required this.rating,
    required this.reviewCount,
    this.isAvailable = true,
    required this.postedAt,
  });
}

/// Report model
class OrderReport {
  final String orderId;
  final String reason;
  final String description;
  final List<String> evidenceUrls;
  final DateTime createdAt;

  OrderReport({
    required this.orderId,
    required this.reason,
    required this.description,
    this.evidenceUrls = const [],
    required this.createdAt,
  });
}
