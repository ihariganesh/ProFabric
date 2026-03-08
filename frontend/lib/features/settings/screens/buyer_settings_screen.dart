import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

/// Buyer settings with profile management, address, order history, help
class BuyerSettingsScreen extends StatelessWidget {
  const BuyerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // Profile card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF00C853).withOpacity(0.15), const Color(0xFF12AEE2).withOpacity(0.1)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF00C853).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      backgroundColor: const Color(0xFF00C853).withOpacity(0.3),
                      child: user?.photoURL == null
                          ? Text((user?.displayName ?? 'B')[0], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.displayName ?? 'Buyer', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(user?.email ?? '', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFF00C853).withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                            child: const Text('Buyer', style: TextStyle(color: Color(0xFF00C853), fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showEditProfileSheet(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSection('Account', [
                _SettingItem(Icons.person_outline, 'Personal Details', 'Name, email, phone', () => _showEditProfileSheet(context)),
                _SettingItem(Icons.location_on_outlined, 'Addresses', 'Manage delivery addresses', () => _showAddressSheet(context)),
                _SettingItem(Icons.business_outlined, 'Business Info', 'Company name, GST', () {}),
              ]),
              const SizedBox(height: 16),
              _buildSection('Orders', [
                _SettingItem(Icons.history, 'Order History', 'View all past orders', () {}),
                _SettingItem(Icons.star_outline, 'Reviews & Ratings', 'Your vendor reviews', () {}),
                _SettingItem(Icons.flag_outlined, 'My Reports', 'Track reported orders', () {}),
              ]),
              const SizedBox(height: 16),
              _buildSection('Preferences', [
                _SettingItem(Icons.notifications_outlined, 'Notifications', 'Order updates, chat', () {}),
                _SettingItem(Icons.palette_outlined, 'Appearance', 'Theme settings', () {}),
                _SettingItem(Icons.language, 'Language', 'English', () {}),
              ]),
              const SizedBox(height: 16),
              _buildSection('Support', [
                _SettingItem(Icons.help_outline, 'Help & Support', 'FAQ, contact us', () => Navigator.pushNamed(context, '/help-support')),
                _SettingItem(Icons.shield_outlined, 'Privacy Policy', '', () {}),
                _SettingItem(Icons.description_outlined, 'Terms of Service', '', () {}),
                _SettingItem(Icons.info_outline, 'About', 'Version 1.0.0', () => Navigator.pushNamed(context, '/about')),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService().signOut();
                    if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<_SettingItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: const Color(0xFF1A2A30), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
                      child: Icon(item.icon, color: const Color(0xFF12AEE2), size: 20),
                    ),
                    title: Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: item.subtitle.isNotEmpty
                        ? Text(item.subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12))
                        : null,
                    trailing: const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
                  ),
                  if (!isLast) Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 60),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: const BoxDecoration(color: Color(0xFF1A2A30), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField('Full Name', Icons.person_outline),
            const SizedBox(height: 12),
            _buildTextField('Email', Icons.email_outlined),
            const SizedBox(height: 12),
            _buildTextField('Phone', Icons.phone_outlined),
            const SizedBox(height: 12),
            _buildTextField('Company Name', Icons.business_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
        decoration: const BoxDecoration(color: Color(0xFF1A2A30), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Text('My Addresses', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                IconButton(
                  onPressed: () {},
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: const Color(0xFF00C853).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.add, color: Color(0xFF00C853), size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAddressCard('Home', '123, MG Road, Coimbatore\nTamil Nadu - 641001', true),
            const SizedBox(height: 12),
            _buildAddressCard('Office', '456, Industrial Area\nTirupur, Tamil Nadu - 641604', false),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(String label, String address, bool isDefault) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDefault ? const Color(0xFF00C853).withOpacity(0.3) : Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDefault ? const Color(0xFF00C853) : const Color(0xFF12AEE2)).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isDefault ? Icons.home : Icons.business, color: isDefault ? const Color(0xFF00C853) : const Color(0xFF12AEE2), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFF00C853).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Default', style: TextStyle(color: Color(0xFF00C853), fontSize: 9, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(address, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.edit, color: Colors.white24, size: 18),
        ],
      ),
    );
  }

  static Widget _buildTextField(String label, IconData icon) {
    return TextField(
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  _SettingItem(this.icon, this.title, this.subtitle, this.onTap);
}
