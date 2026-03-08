import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firestore-based real-time chat service.
/// Messages are stored in:
///   chats/{chatId}/messages/{messageId}
/// where chatId = sorted UIDs joined by '_'
class FirestoreChatService {
  static final FirestoreChatService _instance =
      FirestoreChatService._internal();
  factory FirestoreChatService() => _instance;
  FirestoreChatService._internal();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  String? get _myUid => FirebaseAuth.instance.currentUser?.uid;

  /// Deterministic chat room ID for any two users.
  String chatId(String uid1, String uid2) {
    final ids = [uid1, uid2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Stream of messages in a chat room, ordered oldest → newest.
  Stream<List<ChatMessage>> messages(String otherUid) {
    final me = _myUid;
    if (me == null) return const Stream.empty();
    final cid = chatId(me, otherUid);
    return _db
        .collection('chats')
        .doc(cid)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatMessage.fromDoc(d)).toList());
  }

  /// Send a message to another user.
  Future<void> sendMessage({
    required String otherUid,
    required String otherName,
    required String text,
    String? myName,
  }) async {
    final me = _myUid;
    if (me == null) return;
    final cid = chatId(me, otherUid);
    final now = FieldValue.serverTimestamp();

    final msgRef =
        _db.collection('chats').doc(cid).collection('messages').doc();
    final batch = _db.batch();

    // Write the message
    batch.set(msgRef, {
      'senderId': me,
      'senderName': myName ?? 'User',
      'text': text,
      'timestamp': now,
      'read': false,
    });

    // Update or create the conversation metadata doc
    final chatRef = _db.collection('chats').doc(cid);
    batch.set(
      chatRef,
      {
        'participants': [me, otherUid],
        'participantNames': {me: myName ?? 'User', otherUid: otherName},
        'lastMessage': text,
        'lastMessageTime': now,
        'lastSenderId': me,
        'updatedAt': now,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Mark all messages in a chat as read by the current user.
  Future<void> markAsRead(String otherUid) async {
    final me = _myUid;
    if (me == null) return;
    final cid = chatId(me, otherUid);

    final snap = await _db
        .collection('chats')
        .doc(cid)
        .collection('messages')
        .where('read', isEqualTo: false)
        .get();

    // Filter out messages sent by me (only mark others' messages as read)
    final toMark = snap.docs.where((d) {
      return (d.data()['senderId'] as String?) != me;
    }).toList();

    if (toMark.isEmpty) return;
    final batch = _db.batch();
    for (final doc in toMark) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  /// Stream of all conversations the current user is part of.
  Stream<List<ChatConversation>> myConversations() {
    final me = _myUid;
    if (me == null) return const Stream.empty();
    return _db
        .collection('chats')
        .where('participants', arrayContains: me)
        .snapshots()
        .asyncMap((snap) async {
      final convs = <ChatConversation>[];
      for (final doc in snap.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants'] ?? []);
        final otherUid =
            participants.firstWhere((p) => p != me, orElse: () => '');
        if (otherUid.isEmpty) continue;

        final names = Map<String, String>.from(data['participantNames'] ?? {});
        final otherName = names[otherUid] ?? 'User';

        // Count unread messages for current user (filter in Dart to avoid composite index)
        final unreadSnap = await doc.reference
            .collection('messages')
            .where('read', isEqualTo: false)
            .get();
        final unread = unreadSnap.docs
            .where((d) => (d.data()['senderId'] as String?) != me)
            .length;

        convs.add(ChatConversation(
          chatId: doc.id,
          otherUid: otherUid,
          otherName: otherName,
          lastMessage: data['lastMessage'] as String? ?? '',
          lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
          unreadCount: unread,
        ));
      }
      convs.sort((a, b) {
        final at = a.lastMessageTime;
        final bt = b.lastMessageTime;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
      return convs;
    });
  }
}

// ─── Data models ────────────────────────────────────────────────────────────

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime? timestamp;
  final bool read;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.timestamp,
    this.read = false,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: d['senderId'] as String? ?? '',
      senderName: d['senderName'] as String? ?? 'User',
      text: d['text'] as String? ?? '',
      timestamp: (d['timestamp'] as Timestamp?)?.toDate(),
      read: d['read'] as bool? ?? false,
    );
  }
}

class ChatConversation {
  final String chatId;
  final String otherUid;
  final String otherName;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatConversation({
    required this.chatId,
    required this.otherUid,
    required this.otherName,
    required this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  String get timeLabel {
    if (lastMessageTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageTime!);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
