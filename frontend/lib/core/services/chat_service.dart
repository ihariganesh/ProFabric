import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

/// Real-time chat service using Socket.IO
/// Handles WebSocket connections for in-app messaging between users
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _currentUserId;
  String? _currentRoomId;

  // Stream controllers for reactive updates
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _typingController = StreamController<TypingStatus>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _onlineUsersController = StreamController<List<String>>.broadcast();

  // Public streams
  Stream<ChatMessage> get onMessage => _messageController.stream;
  Stream<TypingStatus> get onTyping => _typingController.stream;
  Stream<bool> get onConnectionChange => _connectionController.stream;
  Stream<List<String>> get onOnlineUsersChange => _onlineUsersController.stream;

  bool get isConnected => _isConnected;

  /// Initialize and connect to the chat server
  void connect({
    required String userId,
    required String userName,
    required String authToken,
    String serverUrl = 'http://10.0.2.2:8000',
  }) {
    if (_socket != null && _isConnected) {
      print('ChatService: Already connected');
      return;
    }

    _currentUserId = userId;

    _socket = IO.io(
      '$serverUrl/chat',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': authToken})
          .setQuery({'userId': userId, 'userName': userName})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _setupEventListeners();
  }

  void _setupEventListeners() {
    _socket?.onConnect((_) {
      print('ChatService: Connected');
      _isConnected = true;
      _connectionController.add(true);
    });

    _socket?.onDisconnect((_) {
      print('ChatService: Disconnected');
      _isConnected = false;
      _connectionController.add(false);
    });

    _socket?.onConnectError((error) {
      print('ChatService: Connection error - $error');
      _isConnected = false;
      _connectionController.add(false);
    });

    // Listen for incoming messages
    _socket?.on('message', (data) {
      final message = ChatMessage.fromJson(data);
      _messageController.add(message);
    });

    // Listen for typing indicators
    _socket?.on('typing', (data) {
      final typing = TypingStatus.fromJson(data);
      _typingController.add(typing);
    });

    // Listen for online users updates
    _socket?.on('online_users', (data) {
      final users = List<String>.from(data['users'] ?? []);
      _onlineUsersController.add(users);
    });

    // Listen for read receipts
    _socket?.on('message_read', (data) {
      // Handle read receipts
      print('ChatService: Message read by ${data['userId']}');
    });

    // Listen for message delivered
    _socket?.on('message_delivered', (data) {
      print('ChatService: Message delivered - ${data['messageId']}');
    });
  }

  /// Join a chat room (order-specific or direct message)
  void joinRoom(String roomId) {
    if (!_isConnected) {
      print('ChatService: Cannot join room - not connected');
      return;
    }

    _currentRoomId = roomId;
    _socket?.emit('join_room', {'roomId': roomId});
    print('ChatService: Joined room $roomId');
  }

  /// Leave the current chat room
  void leaveRoom() {
    if (_currentRoomId != null) {
      _socket?.emit('leave_room', {'roomId': _currentRoomId});
      print('ChatService: Left room $_currentRoomId');
      _currentRoomId = null;
    }
  }

  /// Send a text message
  void sendMessage({
    required String content,
    required String recipientId,
    String? orderId,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) {
    if (!_isConnected) {
      print('ChatService: Cannot send message - not connected');
      return;
    }

    final message = {
      'content': content,
      'senderId': _currentUserId,
      'recipientId': recipientId,
      'roomId': _currentRoomId,
      'orderId': orderId,
      'type': type.name,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _socket?.emit('send_message', message);
  }

  /// Send an image message
  void sendImage({
    required String imageUrl,
    required String recipientId,
    String? caption,
    String? orderId,
  }) {
    sendMessage(
      content: caption ?? '',
      recipientId: recipientId,
      orderId: orderId,
      type: MessageType.image,
      metadata: {'imageUrl': imageUrl},
    );
  }

  /// Send a file/document
  void sendFile({
    required String fileUrl,
    required String fileName,
    required String recipientId,
    String? orderId,
  }) {
    sendMessage(
      content: fileName,
      recipientId: recipientId,
      orderId: orderId,
      type: MessageType.file,
      metadata: {'fileUrl': fileUrl, 'fileName': fileName},
    );
  }

  /// Send typing indicator
  void sendTyping({required String recipientId, required bool isTyping}) {
    if (!_isConnected) return;

    _socket?.emit('typing', {
      'senderId': _currentUserId,
      'recipientId': recipientId,
      'roomId': _currentRoomId,
      'isTyping': isTyping,
    });
  }

  /// Mark messages as read
  void markAsRead({required String messageId, required String senderId}) {
    if (!_isConnected) return;

    _socket?.emit('mark_read', {
      'messageId': messageId,
      'readerId': _currentUserId,
      'senderId': senderId,
    });
  }

  /// Get online status of a user
  void requestOnlineStatus(String userId) {
    _socket?.emit('get_online_status', {'userId': userId});
  }

  /// Disconnect from the chat server
  void disconnect() {
    leaveRoom();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
    _currentUserId = null;
    print('ChatService: Disconnected and disposed');
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _messageController.close();
    _typingController.close();
    _connectionController.close();
    _onlineUsersController.close();
  }
}

/// Enum for message types
enum MessageType {
  text,
  image,
  file,
  audio,
  location,
  system,
  orderUpdate,
}

/// Chat message model
class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String recipientId;
  final String? roomId;
  final String? orderId;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;
  final bool isRead;
  final bool isDelivered;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.recipientId,
    this.roomId,
    this.orderId,
    this.type = MessageType.text,
    this.metadata,
    required this.timestamp,
    this.isRead = false,
    this.isDelivered = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? json['messageId'] ?? '',
      content: json['content'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Unknown',
      senderAvatar: json['senderAvatar'],
      recipientId: json['recipientId'] ?? '',
      roomId: json['roomId'],
      orderId: json['orderId'],
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      isDelivered: json['isDelivered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'recipientId': recipientId,
      'roomId': roomId,
      'orderId': orderId,
      'type': type.name,
      'metadata': metadata,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isDelivered': isDelivered,
    };
  }

  bool get isFromMe => senderId == ChatService()._currentUserId;
}

/// Typing status model
class TypingStatus {
  final String senderId;
  final String senderName;
  final bool isTyping;

  TypingStatus({
    required this.senderId,
    required this.senderName,
    required this.isTyping,
  });

  factory TypingStatus.fromJson(Map<String, dynamic> json) {
    return TypingStatus(
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Someone',
      isTyping: json['isTyping'] ?? false,
    );
  }
}

/// Chat room model for conversations
class ChatRoom {
  final String id;
  final String name;
  final String? orderId;
  final List<String> participantIds;
  final ChatMessage? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    required this.name,
    this.orderId,
    required this.participantIds,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Chat',
      orderId: json['orderId'],
      participantIds: List<String>.from(json['participantIds'] ?? []),
      lastMessage: json['lastMessage'] != null
          ? ChatMessage.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}
