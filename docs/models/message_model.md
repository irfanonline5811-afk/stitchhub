# MessageModel Documentation

## Overview
`MessageModel` represents a message in the chat system between customers and tailors. Also includes `ChatConversationModel` for managing conversations.

## File Location
`lib/models/message_model.dart`

## Enums

### MessageType
- `text` - Text message
- `image` - Image message

## MessageModel Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String` | Yes | Unique message identifier |
| `senderId` | `String` | Yes | ID of the message sender |
| `receiverId` | `String` | Yes | ID of the message receiver |
| `senderName` | `String` | Yes | Name of the sender |
| `receiverName` | `String` | Yes | Name of the receiver |
| `orderId` | `String?` | No | Optional order ID link |
| `content` | `String` | Yes | Message content (text or image URL) |
| `type` | `MessageType` | No | Message type (default: text) |
| `isRead` | `bool` | No | Read status (default: false) |
| `createdAt` | `DateTime` | Yes | Message creation timestamp |

## ChatConversationModel Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `id` | `String` | Yes | Conversation ID (sorted user IDs) |
| `userId1` | `String` | Yes | First user ID |
| `userId2` | `String` | Yes | Second user ID |
| `userName1` | `String` | Yes | First user name |
| `userName2` | `String` | Yes | Second user name |
| `user1ImageUrl` | `String?` | No | First user image URL |
| `user2ImageUrl` | `String?` | No | Second user image URL |
| `lastMessage` | `String` | Yes | Last message content |
| `lastMessageTime` | `DateTime` | Yes | Last message timestamp |
| `unreadCount` | `int` | No | Unread message count (default: 0) |
| `isUser1Tailor` | `bool` | Yes | Whether user1 is a tailor |
| `isUser2Tailor` | `bool` | Yes | Whether user2 is a tailor |

## Methods

### MessageModel
- `fromMap(Map<String, dynamic> map)` - Factory constructor
- `toMap()` - Convert to map
- `copyWith({...})` - Create copy with updates

### ChatConversationModel
- `fromMap(Map<String, dynamic> map)` - Factory constructor
- `toMap()` - Convert to map

## Usage Example

```dart
// Create a message
final message = MessageModel(
  id: 'message123',
  senderId: 'customer123',
  receiverId: 'tailor123',
  senderName: 'John Doe',
  receiverName: 'Jane Tailor',
  content: 'Hello, I need a custom shirt',
  type: MessageType.text,
  createdAt: DateTime.now(),
);

// Create a conversation
final conversation = ChatConversationModel(
  id: 'conv123',
  userId1: 'customer123',
  userId2: 'tailor123',
  userName1: 'John Doe',
  userName2: 'Jane Tailor',
  lastMessage: 'Hello, I need a custom shirt',
  lastMessageTime: DateTime.now(),
  isUser1Tailor: false,
  isUser2Tailor: true,
);
```

## Related Files
- `lib/services/chat_service.dart` - Chat operations
- `lib/providers/chat_provider.dart` - Chat state management
- `lib/screens/customer/chat_detail_screen.dart` - Chat UI

