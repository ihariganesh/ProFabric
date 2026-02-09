import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _authService = AuthService();
  bool _isUpdating = false;

  void _editProfile() {
    final user = _authService.currentUser;
    final nameController = TextEditingController(text: user?.displayName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D33),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Display Name',
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF12AEE2)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                Navigator.pop(context);
                setState(() => _isUpdating = true);
                try {
                  await _authService.updateDisplayName(newName);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isUpdating = false);
                  }
                }
              }
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFF12AEE2))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: const Color(0xFF1E2D33),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.photoURL != null 
                    ? NetworkImage(user!.photoURL!) 
                    : const NetworkImage('https://avatar.iran.liara.run/public/42'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user?.displayName ?? 'User Name',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Center(
                child: Text(
                  user?.email ?? 'user@example.com',
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 32),
              _buildSettingsTile(
                icon: Icons.person,
                title: 'Edit Profile',
                onTap: _editProfile,
              ),
              _buildSettingsTile(icon: Icons.lock, title: 'Change Password', onTap: () {}),
              _buildSettingsTile(icon: Icons.notifications, title: 'Notification Preferences', onTap: () {}),
            ],
          ),
          if (_isUpdating)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF12AEE2)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF12AEE2)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
      onTap: onTap,
    );
  }
}

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: const Color(0xFF1E2D33),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
            value: true,
            onChanged: (val) {},
            activeColor: const Color(0xFF12AEE2),
            secondary: const Icon(Icons.dark_mode, color: Color(0xFF12AEE2)),
          ),
          SwitchListTile(
            title: const Text('Notifications', style: TextStyle(color: Colors.white)),
            value: true,
            onChanged: (val) {},
            activeColor: const Color(0xFF12AEE2),
            secondary: const Icon(Icons.notifications, color: Color(0xFF12AEE2)),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Color(0xFF12AEE2)),
            title: const Text('Language', style: TextStyle(color: Colors.white)),
            subtitle: const Text('English', style: TextStyle(color: Colors.white54)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF1E2D33),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'FAQ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          _buildFaqItem('How do I list a fabric?', 'Go to the Marketplace and click the "+" button.'),
          _buildFaqItem('How do I track my order?', 'Visit the "Orders" section in your dashboard.'),
          const SizedBox(height: 32),
          const Text(
            'Contact Us',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.email, color: Color(0xFF12AEE2)),
            title: const Text('support@fabricflow.com', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Color(0xFF12AEE2)),
            title: const Text('+1 (800) 123-4567', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer, style: const TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D22),
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: const Color(0xFF1E2D33),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF12AEE2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.polyline_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'FabricFlow',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 32),
            const Text(
              '© 2024 FabricFlow Inc.',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
