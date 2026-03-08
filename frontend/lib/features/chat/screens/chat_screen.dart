import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firestore_chat_service.dart';

/// Full-featured chat screen — backed by Firestore real-time messaging.
class ChatScreen extends StatefulWidget {
  final String orderId;
  final String recipientName;
  final String recipientRole;
  final String? recipientId;

  const ChatScreen({
    super.key,
    required this.orderId,
    required this.recipientName,
    required this.recipientRole,
    this.recipientId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scroll = ScrollController();
  final _chatSvc = FirestoreChatService();

  StreamSubscription<List<ChatMessage>>? _msgSub;
  List<ChatMessage> _messages = [];
  bool _sending = false;

  String get _myUid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String get _myName =>
      FirebaseAuth.instance.currentUser?.displayName ??
      FirebaseAuth.instance.currentUser?.email?.split('@').first ??
      'User';

  @override
  void initState() {
    super.initState();
    if (widget.recipientId != null && widget.recipientId!.isNotEmpty) {
      _msgSub = _chatSvc.messages(widget.recipientId!).listen((msgs) {
        if (mounted) {
          setState(() => _messages = msgs);
          _scrollDown();
          _chatSvc.markAsRead(widget.recipientId!);
        }
      });
    }
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _msgCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '';
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:${dt.minute.toString().padLeft(2, '0')} $p';
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final txt = _msgCtrl.text.trim();
    if (txt.isEmpty || _sending) return;
    if (widget.recipientId == null || widget.recipientId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot send: recipient not identified.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _sending = true);
    _msgCtrl.clear();
    try {
      await _chatSvc.sendMessage(
        otherUid: widget.recipientId!,
        otherName: widget.recipientName,
        text: txt,
        myName: _myName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _sendMedia(String type) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${type == 'image' ? 'Photo' : type == 'video' ? 'Video' : 'Document'} sharing coming soon!'),
        backgroundColor: const Color(0xFF00B0FF),
      ),
    );
  }

  // ─── BUILD ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1015),
      appBar: _appBar(),
      body: Column(
        children: [
          _encryptionBanner(),
          Expanded(child: _messageList()),
          _inputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: const Color(0xFF111D23),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: _showContactInfo,
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF00B0FF).withOpacity(0.15),
              child: Text(
                widget.recipientName.isNotEmpty ? widget.recipientName[0] : '?',
                style: const TextStyle(
                    color: Color(0xFF00B0FF), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.recipientName,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(widget.recipientRole,
                      style:
                          const TextStyle(fontSize: 10, color: Colors.white38)),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: Colors.white54),
          onPressed: () => _snack('Video call coming soon!'),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onPressed: _showOptions,
        ),
      ],
    );
  }

  Widget _encryptionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: const Color(0xFF00B0FF).withOpacity(0.06),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 12, color: Colors.white30),
          SizedBox(width: 6),
          Text(
            'Messages are secured via Firestore',
            style: TextStyle(fontSize: 10, color: Colors.white30),
          ),
        ],
      ),
    );
  }

  Widget _messageList() {
    if (widget.recipientId == null || widget.recipientId!.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Cannot load chat:\nrecipient not identified.',
            style: TextStyle(color: Colors.white38),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet. Say hello! 👋',
          style: TextStyle(color: Colors.white24, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (_, i) {
        final m = _messages[i];
        final isMe = m.senderId == _myUid;
        return Column(
          children: [
            if (i == 0) _dateBadge('Today'),
            _bubble(m, isMe),
          ],
        );
      },
    );
  }

  Widget _dateBadge(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(text,
              style: const TextStyle(color: Colors.white24, fontSize: 11)),
        ),
      ),
    );
  }

  Widget _bubble(ChatMessage m, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF00B0FF) : const Color(0xFF111D23),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          border:
              isMe ? null : Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    m.senderName,
                    style: TextStyle(
                        color: const Color(0xFF00B0FF).withOpacity(0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              Text(
                m.text,
                style: TextStyle(
                    color: isMe ? Colors.white : Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    height: 1.4),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _fmt(m.timestamp),
                    style: TextStyle(
                        color: isMe
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white24,
                        fontSize: 10),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      m.read ? Icons.done_all : Icons.done,
                      size: 14,
                      color: m.read
                          ? const Color(0xFF00E676)
                          : Colors.white.withOpacity(0.4),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Input Bar ──────────────────────────────────────────────────────

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111D23),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.04))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white54),
                onPressed: _showAttachmentPicker,
              ),
            ),
            const SizedBox(width: 10),
            // Text field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _msgCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onSubmitted: (_) => _send(),
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: 'Type a message…',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Send button
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00B0FF), Color(0xFF00E676)],
                ),
                shape: BoxShape.circle,
              ),
              child: _sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                      onPressed: _send,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Attachment Picker ──────────────────────────────────────────────
  void _showAttachmentPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111D23),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share Media',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachBtn(Icons.image_rounded, 'Gallery', Colors.purple,
                    () => _sendMedia('image')),
                _attachBtn(Icons.camera_alt_rounded, 'Camera', Colors.pink,
                    () => _sendMedia('image')),
                _attachBtn(Icons.videocam_rounded, 'Video', Colors.blue,
                    () => _sendMedia('video')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachBtn(Icons.insert_drive_file_rounded, 'Document',
                    Colors.orange, () => _sendMedia('file')),
                _attachBtn(Icons.location_on_rounded, 'Location', Colors.green,
                    () {
                  Navigator.pop(context);
                  _snack('Location sharing coming soon');
                }),
                _attachBtn(Icons.texture_rounded, 'Sample', Colors.teal, () {
                  Navigator.pop(context);
                  _snack('Sample request sent');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  void _showContactInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111D23),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF00B0FF).withOpacity(0.15),
              child: Text(
                widget.recipientName.isNotEmpty ? widget.recipientName[0] : '?',
                style: const TextStyle(
                    color: Color(0xFF00B0FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 28),
              ),
            ),
            const SizedBox(height: 14),
            Text(widget.recipientName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.recipientRole,
                style: const TextStyle(color: Colors.white38, fontSize: 14)),
            Text('Order #${widget.orderId}',
                style: const TextStyle(color: Colors.white24, fontSize: 12)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoBubble(Icons.phone_rounded, 'Call'),
                _infoBubble(Icons.videocam_rounded, 'Video'),
                _infoBubble(Icons.folder_rounded, 'Files'),
                _infoBubble(Icons.search_rounded, 'Search'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBubble(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF00B0FF), size: 22),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
    );
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111D23),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search, color: Colors.white54),
              title: const Text('Search in Chat',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.notifications_off, color: Colors.white54),
              title: const Text('Mute Notifications',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Report', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF00B0FF)),
    );
  }
}
