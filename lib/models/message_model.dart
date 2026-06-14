enum MessageType {
  text,
  image,
  audio,
}

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? senderName;
  final String? receiverName;
  final String? orderId; // Optional: link message to an order
  final String content;
  final MessageType type;
  final bool isRead;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.senderName,
    this.receiverName,
    this.orderId,
    required this.content,
    this.type = MessageType.text,
    this.isRead = false,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id']?.toString() ?? '',
      senderId: (map['sender_id'] ?? map['senderId'] ?? '').toString().trim(),
      receiverId: (map['receiver_id'] ?? map['receiverId'] ?? '').toString().trim(),
      senderName: map['sender_name'] ?? map['senderName'],
      receiverName: map['receiver_name'] ?? map['receiverName'],
      orderId: map['order_id']?.toString(),
      content: map['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => MessageType.text,
      ),
      isRead: map['status'] == 'read' || (map['is_read'] ?? map['isRead'] ?? false),
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString())
          : DateTime.fromMillisecondsSinceEpoch(int.tryParse(map['createdAt']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'order_id': orderId,
      'content': content,
      'type': type.toString().split('.').last,
      'status': isRead ? 'read' : 'sent',
      'created_at': createdAt.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? senderName,
    String? receiverName,
    String? orderId,
    String? content,
    MessageType? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      receiverName: receiverName ?? this.receiverName,
      orderId: orderId ?? this.orderId,
      content: content ?? this.content,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Chat conversation model
class ChatConversationModel {
  final String id;
  final String userId1;
  final String userId2;
  final String? userName1;
  final String? userName2;
  final String? user1ImageUrl;
  final String? user2ImageUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isUser1Tailor;
  final bool isUser2Tailor;

  ChatConversationModel({
    required this.id,
    required this.userId1,
    required this.userId2,
    this.userName1,
    this.userName2,
    this.user1ImageUrl,
    this.user2ImageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    required this.isUser1Tailor,
    required this.isUser2Tailor,
  });

  factory ChatConversationModel.fromMap(Map<String, dynamic> map, {String? currentUserId}) {
    final otherId = (map['other_user_id'] ?? map['userId2'] ?? '').toString().trim();
    final otherName = map['other_user_name'] ?? map['userName2'];
    final otherImage = map['other_user_image'] ?? map['user2ImageUrl'];
    
    // If we have a currentUserId, we can determine userId1 and userId2 more accurately
    String uid1 = (map['userId1'] ?? map['user_id1'] ?? '').toString().trim();
    String uid2 = (map['userId2'] ?? map['user_id2'] ?? otherId).toString().trim();
    
    if (currentUserId != null && uid1.isEmpty) {
      uid1 = currentUserId;
    }

    return ChatConversationModel(
      id: map['id']?.toString() ?? otherId,
      userId1: uid1,
      userId2: uid2,
      userName1: map['userName1'] ?? map['user_name1'],
      userName2: otherName,
      user1ImageUrl: map['user1ImageUrl'] ?? map['user_1_image_url'],
      user2ImageUrl: otherImage,
      lastMessage: map['last_message'] ?? map['lastMessage'] ?? '',
      lastMessageTime: map['last_message_time'] != null 
          ? DateTime.parse(map['last_message_time'].toString())
          : DateTime.fromMillisecondsSinceEpoch(int.tryParse(map['lastMessageTime']?.toString() ?? '0') ?? 0),
      unreadCount: int.tryParse(map['unread_count']?.toString() ?? '0') ?? 0,
      isUser1Tailor: map['isUser1Tailor'] ?? map['is_user1_tailor'] ?? false,
      isUser2Tailor: map['isUser2Tailor'] ?? map['is_user2_tailor'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId1': userId1,
      'userId2': userId2,
      'userName1': userName1,
      'userName2': userName2,
      'user1ImageUrl': user1ImageUrl,
      'user2ImageUrl': user2ImageUrl,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'isUser1Tailor': isUser1Tailor,
      'isUser2Tailor': isUser2Tailor,
    };
  }

  ChatConversationModel copyWith({
    String? userName1,
    String? userName2,
    String? user1ImageUrl,
    String? user2ImageUrl,
    int? unreadCount,
  }) {
    return ChatConversationModel(
      id: id,
      userId1: userId1,
      userId2: userId2,
      userName1: userName1 ?? this.userName1,
      userName2: userName2 ?? this.userName2,
      user1ImageUrl: user1ImageUrl ?? this.user1ImageUrl,
      user2ImageUrl: user2ImageUrl ?? this.user2ImageUrl,
      lastMessage: lastMessage,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isUser1Tailor: isUser1Tailor,
      isUser2Tailor: isUser2Tailor,
    );
  }
}
