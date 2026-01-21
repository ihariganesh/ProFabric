class Order {
  final int orderId;
  final int buyerId;
  final String? designPrompt;
  final String? generatedImageUrl;
  final String fabricType;
  final int quantityMeters;
  final int? threadCount;
  final int? gsm;
  final String status;
  final double? totalCost;
  final double? optimizationScore;
  final DateTime createdAt;
  final DateTime? estimatedDelivery;

  Order({
    required this.orderId,
    required this.buyerId,
    this.designPrompt,
    this.generatedImageUrl,
    required this.fabricType,
    required this.quantityMeters,
    this.threadCount,
    this.gsm,
    required this.status,
    this.totalCost,
    this.optimizationScore,
    required this.createdAt,
    this.estimatedDelivery,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'] as int,
      buyerId: json['buyer_id'] as int,
      designPrompt: json['design_prompt'] as String?,
      generatedImageUrl: json['generated_image_url'] as String?,
      fabricType: json['fabric_type'] as String,
      quantityMeters: json['quantity_meters'] as int,
      threadCount: json['thread_count'] as int?,
      gsm: json['gsm'] as int?,
      status: json['status'] as String,
      totalCost: json['total_cost'] != null 
          ? (json['total_cost'] as num).toDouble() 
          : null,
      optimizationScore: json['optimization_score'] != null
          ? (json['optimization_score'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'buyer_id': buyerId,
      'design_prompt': designPrompt,
      'generated_image_url': generatedImageUrl,
      'fabric_type': fabricType,
      'quantity_meters': quantityMeters,
      'thread_count': threadCount,
      'gsm': gsm,
      'status': status,
      'total_cost': totalCost,
      'optimization_score': optimizationScore,
      'created_at': createdAt.toIso8601String(),
      'estimated_delivery': estimatedDelivery?.toIso8601String(),
    };
  }
}

class BOMItem {
  final String materialName;
  final String materialType;
  final double quantityRequired;
  final String unit;
  final double estimatedCost;

  BOMItem({
    required this.materialName,
    required this.materialType,
    required this.quantityRequired,
    required this.unit,
    required this.estimatedCost,
  });

  factory BOMItem.fromJson(Map<String, dynamic> json) {
    return BOMItem(
      materialName: json['material_name'] as String,
      materialType: json['material_type'] as String,
      quantityRequired: (json['quantity_required'] as num).toDouble(),
      unit: json['unit'] as String,
      estimatedCost: (json['estimated_cost'] as num).toDouble(),
    );
  }
}
