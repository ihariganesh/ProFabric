import '../../../core/services/api_service.dart';

/// Service for AI fabric design generation and vendor matching
class AIDesignService {
  final ApiService _api;

  AIDesignService({ApiService? api}) : _api = api ?? ApiService();

  /// Generate AI fabric design based on prompt
  Future<AIDesignResult> generateDesign({
    required String prompt,
    String? colorHex,
    String? threadType,
    int? quantity,
  }) async {
    try {
      final response = await _api.post('/ai/generate-design', {
        'prompt': prompt,
        'color_hex': colorHex,
        'thread_type': threadType,
        'quantity': quantity,
      });

      return AIDesignResult.fromJson(response);
    } catch (e) {
      throw AIDesignException(
        message: e.toString(),
        code: 500,
      );
    }
  }

  /// Calculate Bill of Materials for a design
  Future<BOMResult> calculateBOM({
    required String fabricType,
    required int quantityMeters,
    required int threadCount,
    required int gsm,
  }) async {
    try {
      final response = await _api.post('/ai/calculate-bom', {
        'fabric_type': fabricType,
        'quantity_meters': quantityMeters,
        'thread_count': threadCount,
        'gsm': gsm,
      });

      return BOMResult.fromJson(response);
    } catch (e) {
      throw AIDesignException(
        message: e.toString(),
        code: 500,
      );
    }
  }

  /// Find best matching vendors for a design
  Future<List<VendorMatch>> findVendors({
    required String fabricType,
    required int quantity,
    required String deliveryLocation,
    String? designId,
  }) async {
    try {
      final response = await _api.post('/ai/find-vendors', {
        'fabric_type': fabricType,
        'quantity': quantity,
        'delivery_location': deliveryLocation,
        'design_id': designId,
      });

      return (response['vendors'] as List? ?? [])
          .map((v) => VendorMatch.fromJson(v))
          .toList();
    } catch (e) {
      throw AIDesignException(
        message: e.toString(),
        code: 500,
      );
    }
  }

  /// Get similar designs from gallery
  Future<List<DesignSuggestion>> getSimilarDesigns(String prompt) async {
    try {
      final response = await _api.get('/ai/similar-designs?prompt=$prompt');

      return (response['designs'] as List? ?? [])
          .map((d) => DesignSuggestion.fromJson(d))
          .toList();
    } catch (e) {
      throw AIDesignException(
        message: e.toString(),
        code: 500,
      );
    }
  }

  /// Enhance user prompt with AI suggestions
  Future<String> enhancePrompt(String prompt) async {
    try {
      final response = await _api.post('/ai/enhance-prompt', {
        'prompt': prompt,
      });

      return response['enhanced_prompt'] ?? prompt;
    } catch (e) {
      // Fallback to original prompt if enhancement fails
      return prompt;
    }
  }
}

// Models

class AIDesignResult {
  final String designId;
  final String imageUrl;
  final String prompt;
  final Map<String, dynamic> specifications;
  final List<String> colorPalette;
  final double estimatedCostPerMeter;
  final int productionDays;

  AIDesignResult({
    required this.designId,
    required this.imageUrl,
    required this.prompt,
    required this.specifications,
    required this.colorPalette,
    required this.estimatedCostPerMeter,
    required this.productionDays,
  });

  factory AIDesignResult.fromJson(Map<String, dynamic> json) {
    return AIDesignResult(
      designId: json['design_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      prompt: json['prompt'] ?? '',
      specifications: json['specifications'] ?? {},
      colorPalette: List<String>.from(json['color_palette'] ?? []),
      estimatedCostPerMeter: (json['estimated_cost_per_meter'] ?? 0).toDouble(),
      productionDays: json['production_days'] ?? 0,
    );
  }
}

class BOMResult {
  final List<BOMItem> items;
  final double totalCost;
  final double laborCost;
  final double overheadCost;
  final double grandTotal;

  BOMResult({
    required this.items,
    required this.totalCost,
    required this.laborCost,
    required this.overheadCost,
    required this.grandTotal,
  });

  factory BOMResult.fromJson(Map<String, dynamic> json) {
    return BOMResult(
      items: (json['items'] as List? ?? [])
          .map((i) => BOMItem.fromJson(i))
          .toList(),
      totalCost: (json['total_cost'] ?? 0).toDouble(),
      laborCost: (json['labor_cost'] ?? 0).toDouble(),
      overheadCost: (json['overhead_cost'] ?? 0).toDouble(),
      grandTotal: (json['grand_total'] ?? 0).toDouble(),
    );
  }
}

class BOMItem {
  final String material;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;

  BOMItem({
    required this.material,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory BOMItem.fromJson(Map<String, dynamic> json) {
    return BOMItem(
      material: json['material'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
    );
  }
}

class VendorMatch {
  final String vendorId;
  final String name;
  final String location;
  final double rating;
  final int completedOrders;
  final double pricePerMeter;
  final int deliveryDays;
  final double matchScore;
  final List<String> capabilities;
  final String imageUrl;

  VendorMatch({
    required this.vendorId,
    required this.name,
    required this.location,
    required this.rating,
    required this.completedOrders,
    required this.pricePerMeter,
    required this.deliveryDays,
    required this.matchScore,
    required this.capabilities,
    required this.imageUrl,
  });

  factory VendorMatch.fromJson(Map<String, dynamic> json) {
    return VendorMatch(
      vendorId: json['vendor_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      completedOrders: json['completed_orders'] ?? 0,
      pricePerMeter: (json['price_per_meter'] ?? 0).toDouble(),
      deliveryDays: json['delivery_days'] ?? 0,
      matchScore: (json['match_score'] ?? 0).toDouble(),
      capabilities: List<String>.from(json['capabilities'] ?? []),
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class DesignSuggestion {
  final String designId;
  final String imageUrl;
  final String name;
  final String description;
  final double price;
  final double similarity;

  DesignSuggestion({
    required this.designId,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.price,
    required this.similarity,
  });

  factory DesignSuggestion.fromJson(Map<String, dynamic> json) {
    return DesignSuggestion(
      designId: json['design_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      similarity: (json['similarity'] ?? 0).toDouble(),
    );
  }
}

class AIDesignException implements Exception {
  final String message;
  final int code;

  AIDesignException({required this.message, required this.code});

  @override
  String toString() => 'AIDesignException: $message (code: $code)';
}
