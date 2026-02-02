import 'package:flutter/material.dart';
import '../../core/constants/user_roles.dart';
import '../textile/screens/textile_dashboard_screen.dart';
import '../vendor/screens/vendor_dashboard_screen.dart';
import '../home/screens/home_screen.dart';

/// Role-based dashboard router that directs users to their appropriate dashboard
class RoleDashboardRouter extends StatelessWidget {
  final UserRole userRole;
  final String userName;
  final String userEmail;

  const RoleDashboardRouter({
    super.key,
    required this.userRole,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    switch (userRole) {
      case UserRole.buyer:
        return const HomeScreen(); // Buyer uses the default home screen

      case UserRole.textile:
        return TextileDashboardScreen(
          userName: userName,
          userEmail: userEmail,
        );

      case UserRole.fabricSeller:
      case UserRole.weaver:
      case UserRole.yarnManufacturer:
      case UserRole.printingUnit:
      case UserRole.stitchingUnit:
        return VendorDashboardScreen(
          userRole: userRole,
          userName: userName,
          userEmail: userEmail,
        );

      case UserRole.logistics:
        return VendorDashboardScreen(
          userRole: userRole,
          userName: userName,
          userEmail: userEmail,
        );

      case UserRole.admin:
        return _buildAdminDashboard(context);
    }
  }

  Widget _buildAdminDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 64,
                color: UserRole.admin.themeColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Coming Soon',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
