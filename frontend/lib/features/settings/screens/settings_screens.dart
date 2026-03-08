import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/settings_service.dart';

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
        title:
            const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Display Name',
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
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
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await _authService.updateDisplayName(newName);
                  if (mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text('Profile updated successfully!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isUpdating = false);
                }
              }
            },
            child:
                const Text('Save', style: TextStyle(color: Color(0xFF6C63FF))),
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
                      : const NetworkImage(
                          'https://avatar.iran.liara.run/public/42'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user?.displayName ?? 'User Name',
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Center(
                child: Text(
                  user?.email ?? 'No email set',
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 32),
              _buildSettingsTile(
                icon: Icons.person,
                title: 'Edit Profile',
                onTap: _editProfile,
              ),
              _buildSettingsTile(
                  icon: Icons.lock, title: 'Change Password', onTap: () {}),
              _buildSettingsTile(
                  icon: Icons.notifications,
                  title: 'Notification Preferences',
                  onTap: () {}),
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

  Widget _buildSettingsTile(
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF12AEE2)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
      onTap: onTap,
    );
  }
}

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final _settings = SettingsService.instance;

  bool _isDark = true;
  bool _notifications = true;
  String _language = 'English';

  static const _languages = [
    'English',
    'Hindi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Bengali',
    'Gujarati',
  ];

  @override
  void initState() {
    super.initState();
    _isDark = _settings.isDarkMode;
    _notifications = _settings.notificationsEnabled;
    _language = _settings.language;
  }

  void _showSnack(String msg, {IconData icon = Icons.check_circle_rounded}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: const Color(0xFF6C63FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _pickLanguage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF111D22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const Text('Select Language',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ..._languages.map((lang) {
                final selected = lang == _language;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      setState(() => _language = lang);
                      await _settings.setLanguage(lang);
                      if (mounted) _showSnack('Language set to $lang');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 12),
                      child: Row(children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF6C63FF)
                                    .withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            selected
                                ? Icons.check_rounded
                                : Icons.language_rounded,
                            color: selected
                                ? const Color(0xFF6C63FF)
                                : Colors.white38,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(lang,
                            style: TextStyle(
                                color: selected
                                    ? const Color(0xFF6C63FF)
                                    : Colors.white,
                                fontSize: 15,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.normal)),
                      ]),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D22),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('App Settings',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Appearance'),
            _card([
              _switchTile(
                icon: Icons.dark_mode_rounded,
                title: 'Dark Mode',
                subtitle: _isDark ? 'Using dark theme' : 'Using light theme',
                color: const Color(0xFF6C63FF),
                value: _isDark,
                onChanged: (val) async {
                  setState(() => _isDark = val);
                  await _settings.setDarkMode(val);
                  if (mounted) {
                    _showSnack(
                      val ? 'Dark mode enabled' : 'Light mode enabled',
                      icon: val
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                    );
                  }
                },
              ),
              _divider(),
              _navTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: _language,
                color: const Color(0xFF3F8CFF),
                onTap: _pickLanguage,
              ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('Notifications'),
            _card([
              _switchTile(
                icon: Icons.notifications_rounded,
                title: 'Push Notifications',
                subtitle: _notifications
                    ? 'Receiving alerts and updates'
                    : 'All notifications muted',
                color: const Color(0xFF00C896),
                value: _notifications,
                onChanged: (val) async {
                  setState(() => _notifications = val);
                  await _settings.setNotifications(val);
                  if (mounted) {
                    _showSnack(
                      val ? 'Notifications enabled' : 'Notifications disabled',
                      icon: val
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_off_rounded,
                    );
                  }
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.local_shipping_rounded,
                title: 'Order Alerts',
                subtitle: 'Notify on order status changes',
                color: const Color(0xFFFFB74D),
                value: _notifications,
                onChanged: (val) async {
                  setState(() => _notifications = val);
                  await _settings.setNotifications(val);
                  if (mounted)
                    _showSnack(
                        val ? 'Order alerts enabled' : 'Order alerts disabled');
                },
              ),
              _divider(),
              _switchTile(
                icon: Icons.handshake_rounded,
                title: 'Vendor Responses',
                subtitle: 'Alert when vendor accepts your request',
                color: const Color(0xFF3F8CFF),
                value: _notifications,
                onChanged: (val) async {
                  setState(() => _notifications = val);
                  await _settings.setNotifications(val);
                  if (mounted)
                    _showSnack(val
                        ? 'Vendor alerts enabled'
                        : 'Vendor alerts disabled');
                },
              ),
            ]),
            const SizedBox(height: 20),
            _sectionLabel('Data & Privacy'),
            _card([
              _navTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our data usage policy',
                color: Colors.white38,
                onTap: () => _showSnack('Opening Privacy Policy...'),
              ),
              _divider(),
              _navTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'View terms and conditions',
                color: Colors.white38,
                onTap: () => _showSnack('Opening Terms of Service...'),
              ),
              _divider(),
              _navTile(
                icon: Icons.delete_sweep_rounded,
                title: 'Clear Cache',
                subtitle: 'Free up local storage',
                color: const Color(0xFFEF5350),
                onTap: () =>
                    _showSnack('Cache cleared!', icon: Icons.done_all_rounded),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111D22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        ),
        child: Column(children: children),
      );

  Widget _divider() => Divider(
      height: 1, indent: 70, color: Colors.white.withValues(alpha: 0.05));

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
          ]),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: color,
          activeTrackColor: color.withValues(alpha: 0.25),
          inactiveThumbColor: Colors.white38,
          inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
        ),
      ]),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 11)),
                  ]),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.15), size: 18),
          ]),
        ),
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D22),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Help & Support',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3F8CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 40),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text('Need Help?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Our team responds within 24 hours',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13)),
                    ])),
              ]),
            ),
            const SizedBox(height: 28),

            // FAQs
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text('Frequently Asked Questions',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111D22),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: Column(children: [
                _faqTile(context, 'How do I place a fabric request?',
                    'Tap the + button at the bottom. Choose Design Studio, Upload Sample, or Manual Description.'),
                _faqTile(context, 'How does AI vendor matching work?',
                    'After creating a design, our AI matches requirements with textile vendors by speciality, capacity, and location.'),
                _faqTile(context, 'How do I track my order?',
                    'Visit the Orders tab. Each card shows real-time status with detailed tracking on tap.'),
                _faqTile(
                    context,
                    'What happens after I confirm a vendor request?',
                    'The vendor has 24 hours to accept. You will get a notification in the Notifications tab when they respond.'),
                _faqTile(context, 'How do I contact a vendor?',
                    'Once a vendor accepts, the Messages tab will open a chat with them.'),
              ]),
            ),
            const SizedBox(height: 24),

            // Contact
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text('Contact Us',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111D22),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              ),
              child: Column(children: [
                _contactTile(Icons.email_rounded, 'Email Support',
                    'support@fabricflow.com', const Color(0xFF6C63FF)),
                Divider(
                    height: 1,
                    indent: 70,
                    color: Colors.white.withValues(alpha: 0.05)),
                _contactTile(Icons.phone_rounded, 'Phone', '+91 98765 43210',
                    const Color(0xFF3F8CFF)),
                Divider(
                    height: 1,
                    indent: 70,
                    color: Colors.white.withValues(alpha: 0.05)),
                _contactTile(Icons.chat_bubble_outline_rounded, 'Live Chat',
                    'Available 9AM–6PM IST', const Color(0xFF00C896)),
              ]),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(BuildContext context, String q, String a) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: const Color(0xFF6C63FF),
        collapsedIconColor: Colors.white38,
        title: Text(q,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(a,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    height: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _contactTile(IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
        ]),
      ]),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1215),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111D22),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('About FabricFlow',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 48),
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3F8CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
                    blurRadius: 32,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Icon(Icons.polyline_rounded,
                  size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('FabricFlow',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text('Version 1.0.0',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4), fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00C896).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Stable Release',
                  style: TextStyle(
                      color: Color(0xFF00C896),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 36),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111D22),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: Text(
                  'FabricFlow connects textile buyers with manufacturers, weavers, and fabric sellers across India. Powered by AI-driven design matching and real-time logistics.',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                _stat('500+', 'Vendors', const Color(0xFF6C63FF)),
                const SizedBox(width: 12),
                _stat('10K+', 'Orders', const Color(0xFF3F8CFF)),
                const SizedBox(width: 12),
                _stat('28', 'States', const Color(0xFF00C896)),
              ]),
            ),
            const SizedBox(height: 40),
            Text('© 2026 FabricFlow Technologies Pvt. Ltd.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25), fontSize: 12)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
        ]),
      ),
    );
  }
}
