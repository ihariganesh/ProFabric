import 'package:flutter/material.dart';

/// User roles for the textile supply chain platform
enum UserRole {
  buyer,
  textile,
  fabricSeller,
  weaver,
  yarnManufacturer,
  printingUnit,
  stitchingUnit,
  logistics,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.buyer:
        return 'Buyer';
      case UserRole.textile:
        return 'Textile Orchestrator';
      case UserRole.fabricSeller:
        return 'Fabric Seller';
      case UserRole.weaver:
        return 'Weaver';
      case UserRole.yarnManufacturer:
        return 'Yarn Manufacturer';
      case UserRole.printingUnit:
        return 'Printing Unit';
      case UserRole.stitchingUnit:
        return 'Stitching Unit';
      case UserRole.logistics:
        return 'Logistics Partner';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.buyer:
        return Icons.shopping_cart;
      case UserRole.textile:
        return Icons.hub;
      case UserRole.fabricSeller:
        return Icons.store;
      case UserRole.weaver:
        return Icons.texture;
      case UserRole.yarnManufacturer:
        return Icons.settings_suggest;
      case UserRole.printingUnit:
        return Icons.print;
      case UserRole.stitchingUnit:
        return Icons.content_cut;
      case UserRole.logistics:
        return Icons.local_shipping;
      case UserRole.admin:
        return Icons.admin_panel_settings;
    }
  }

  Color get themeColor {
    switch (this) {
      case UserRole.buyer:
        return const Color(0xFF12AEE2);
      case UserRole.textile:
        return const Color(0xFF9C27B0);
      case UserRole.fabricSeller:
        return const Color(0xFF4CAF50);
      case UserRole.weaver:
        return const Color(0xFFFF9800);
      case UserRole.yarnManufacturer:
        return const Color(0xFF607D8B);
      case UserRole.printingUnit:
        return const Color(0xFFE91E63);
      case UserRole.stitchingUnit:
        return const Color(0xFF3F51B5);
      case UserRole.logistics:
        return const Color(0xFF795548);
      case UserRole.admin:
        return const Color(0xFFF44336);
    }
  }

  static UserRole fromString(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'buyer':
        return UserRole.buyer;
      case 'textile':
        return UserRole.textile;
      case 'fabric_seller':
      case 'fabricseller':
        return UserRole.fabricSeller;
      case 'weaver':
        return UserRole.weaver;
      case 'yarn_manufacturer':
      case 'yarnmanufacturer':
        return UserRole.yarnManufacturer;
      case 'printing_unit':
      case 'printingunit':
        return UserRole.printingUnit;
      case 'stitching_unit':
      case 'stitchingunit':
        return UserRole.stitchingUnit;
      case 'logistics':
        return UserRole.logistics;
      case 'supply_partner':
        // Generic supply partner — treat as fabric seller until sub-role is resolved
        return UserRole.fabricSeller;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.buyer;
    }
  }
}
