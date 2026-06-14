import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:async';
import '../models/message_model.dart';

class ChatService {
  final _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  // Upload audio file
  Future<String?> uploadAudio(String path) async {
    try {
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final file = File(path);
      
      await _supabase.storage
          .from('chat_audios')
          .upload(fileName, file);
          
      final audioUrl = _supabase.storage
          .from('chat_audios')
          .getPublicUrl(fileName);
          
      return audioUrl;
    } catch (e) {
      debugPrint('Error uploading audio: $e');
      return null;
    }
  }

  // Send a message
  Future<MessageModel> sendMessage({
    required String senderId,
    required String receiverId,
    required String senderName,
    required String receiverName,
    required String content,
    String? orderId,
    MessageType type = MessageType.text,
  }) async {
    if (senderId.trim().isEmpty || receiverId.trim().isEmpty) {
      throw Exception('Invalid user IDs. Cannot send message.');
    }

    try {
      final messageId = _uuid.v4();
      final now = DateTime.now();

      final data = {
        'id': messageId,
        'sender_id': senderId.trim(),
        'receiver_id': receiverId.trim(),
        // sender_name & receiver_name removed — columns don't exist in DB schema
        'content': content,
        'order_id': orderId,
        'type': type.name,
        'status': 'sent',
        // is_read removed as it doesn't exist in DB
        'created_at': now.toIso8601String(),
      };

      await _supabase.from('messages').insert(data);

      return MessageModel(
        id: messageId,
        senderId: senderId,
        receiverId: receiverId,
        senderName: senderName,
        receiverName: receiverName,
        content: content,
        orderId: orderId,
        type: type,
        isRead: false,
        createdAt: now,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Stream for conversations list
  Stream<List<ChatConversationModel>> streamConversations(String uid) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .asyncMap((data) async {
          final userMessages = data.where((m) => 
            m['sender_id'].toString().trim() == uid || 
            m['receiver_id'].toString().trim() == uid
          ).toList();

          Map<String, Map<String, dynamic>> convosMap = {};
          List<String> otherUserIds = [];

          for (var msg in userMessages) {
            final sender = msg['sender_id'].toString().trim();
            final receiver = msg['receiver_id'].toString().trim();
            final otherId = sender == uid ? receiver : sender;

            if (!convosMap.containsKey(otherId)) {
              otherUserIds.add(otherId);
              convosMap[otherId] = {
                'other_id': otherId,
                'last_message': msg['content'] ?? 'Image',
                'last_message_time': msg['created_at'],
                'unread_count': 0,
              };
            }
            if (msg['receiver_id'].toString().trim() == uid && 
                msg['status'] != 'read') {
              convosMap[otherId]!['unread_count'] = (convosMap[otherId]!['unread_count'] as int) + 1;
            }
          }

          // Fetch profiles to avoid "Unknown" or generic "Tailor"
          Map<String, Map<String, String?>> profilesMap = {};
          if (otherUserIds.isNotEmpty) {
            profilesMap = await _getUserProfiles(otherUserIds);
          }

          return convosMap.values.map((c) {
            final profile = profilesMap[c['other_id']];
            return ChatConversationModel(
              id: getConversationId(uid, c['other_id']),
              userId1: uid,
              userId2: c['other_id'],
              userName2: profile?['name'] ?? 'User ${c['other_id'].toString().substring(0, 4)}',
              user2ImageUrl: profile?['image'],
              lastMessage: c['last_message'] ?? '',
              lastMessageTime: DateTime.parse(c['last_message_time']),
              unreadCount: c['unread_count'],
              isUser1Tailor: false,
              isUser2Tailor: profile != null,
            );
          }).toList();
        });
  }

  // Helper to get user profiles — checks both users and tailors tables
  Future<Map<String, Map<String, String?>>> _getUserProfiles(List<String> userIds) async {
    Map<String, Map<String, String?>> profilesMap = {};
    if (userIds.isEmpty) return profilesMap;

    try {
      final cleanIds = userIds.map((id) => id.trim()).where((id) => id.isNotEmpty).toList();
      if (cleanIds.isEmpty) return profilesMap;
      
      debugPrint('ChatService: Looking up profiles for IDs: $cleanIds');

      // 1. Try tailors table first to prioritize business names
      final List<dynamic> tailorsData = await _supabase
          .from('tailors')
          .select('id, name, business_name, profile_image_url')
          .inFilter('id', cleanIds);
      
      debugPrint('ChatService: Found ${tailorsData.length} tailors');
      
      for (var item in tailorsData) {
        final id = item['id'].toString().trim();
        final bName = item['business_name']?.toString();
        final name = item['name']?.toString();
        
        profilesMap[id] = {
          'name': (bName != null && bName.isNotEmpty) ? bName : name,
          'image': item['profile_image_url']?.toString(),
        };
      }

      // 2. Look up in users table for any remaining or to supplement
      final List<dynamic> usersData = await _supabase
          .from('users')
          .select('id, name, profile_image_url')
          .inFilter('id', cleanIds);
          
      debugPrint('ChatService: Found ${usersData.length} users');
      
      for (var item in usersData) {
        final id = item['id'].toString().trim();
        final name = item['name']?.toString();
        final image = item['profile_image_url']?.toString();

        if (!profilesMap.containsKey(id)) {
          profilesMap[id] = {
            'name': name ?? 'User',
            'image': image,
          };
        } else {
          // If already in map (from tailors), only fill if missing or generic
          if (profilesMap[id]!['name'] == null || profilesMap[id]!['name'] == 'Tailor' || profilesMap[id]!['name'] == 'Unknown') {
            if (name != null && name.isNotEmpty) {
              profilesMap[id]!['name'] = name;
            }
          }
          if (profilesMap[id]!['image'] == null) {
            profilesMap[id]!['image'] = image;
          }
        }
      }
      
      debugPrint('ChatService: Successfully resolved ${profilesMap.length} total profiles');
    } catch (e) {
      debugPrint('Error fetching user profiles: $e');
    }
    return profilesMap;
  }


  // Stream messages for real-time updates
  Stream<List<MessageModel>> streamMessages(String userId1, String userId2) {
    if (userId1.isEmpty || userId2.isEmpty) return const Stream.empty();
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) => data
            .where((msg) =>
                (msg['sender_id'] == userId1 && msg['receiver_id'] == userId2) ||
                (msg['sender_id'] == userId2 && msg['receiver_id'] == userId1))
            .map((e) => MessageModel.fromMap(e))
            .toList());
  }

  // Get initial messages
  Future<List<MessageModel>> getMessages(String userId1, String userId2) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .or('and(sender_id.eq.$userId1,receiver_id.eq.$userId2),and(sender_id.eq.$userId2,receiver_id.eq.$userId1)')
          .order('created_at', ascending: true);
      
      return (response as List).map((e) => MessageModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return [];
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String userId1, String userId2, String currentUserId) async {
    if (userId1.isEmpty || userId2.isEmpty || currentUserId.isEmpty) return;
    try {
      final senderId = (userId1.trim() == currentUserId.trim() ? userId2 : userId1).trim();
      final receiverId = currentUserId.trim();

      await _supabase
          .from('messages')
          .update({'status': 'read'}) // is_read removed
          .eq('sender_id', senderId)
          .eq('receiver_id', receiverId);
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Delete a conversation (all messages between two users)
  Future<void> deleteConversation(String userId1, String userId2) async {
    final uid1 = userId1.trim();
    final uid2 = userId2.trim();
    
    if (uid1.isEmpty || uid2.isEmpty) {
      debugPrint('ChatService: Cannot delete conversation, IDs are empty.');
      return;
    }

    try {
      debugPrint('ChatService: [FORCE DELETE] Starting deep cleanup between $uid1 and $uid2');
      
      // Step 1: Fetch all message IDs between these two users
      final List<dynamic> messages = await _supabase
          .from('messages')
          .select('id')
          .or('and(sender_id.eq.$uid1,receiver_id.eq.$uid2),and(sender_id.eq.$uid2,receiver_id.eq.$uid1)');
      
      if (messages.isEmpty) {
        debugPrint('ChatService: No messages found to delete.');
        return;
      }

      final List<String> idsToDelete = messages.map((m) => m['id'].toString()).toList();
      debugPrint('ChatService: Found ${idsToDelete.length} messages to wipe.');

      // Step 2: Delete by specific IDs (this is the most "permanent" way)
      final deleteResult = await _supabase
          .from('messages')
          .delete()
          .inFilter('id', idsToDelete)
          .select('id');
          
      debugPrint('ChatService: Force delete successful. Wiped ${deleteResult.length} messages permanently.');

      // Step 3: Fallback - if some remain, try role-based delete
      if (deleteResult.length < idsToDelete.length) {
        debugPrint('ChatService: Some messages resisted ID deletion, trying role-based cleanup...');
        await _supabase.from('messages').delete().eq('sender_id', uid1).eq('receiver_id', uid2);
        await _supabase.from('messages').delete().eq('sender_id', uid2).eq('receiver_id', uid1);
      }
    } catch (e) {
      debugPrint('ChatService: Force delete failed: $e');
      // Even if it fails, we want the UI to feel like it's gone
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // Get all conversations
  Future<List<ChatConversationModel>> getConversations(String userId) async {
    if (userId.isEmpty || userId == 'null') return [];
    try {
      final uid = userId.trim();
      final List<dynamic> messagesData = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.$uid,receiver_id.eq.$uid')
          .order('created_at', ascending: false);

      Map<String, Map<String, dynamic>> convosMap = {};
      List<String> otherUserIds = [];

      for (var msg in messagesData) {
        final sender = msg['sender_id'].toString().trim();
        final receiver = msg['receiver_id'].toString().trim();
        final otherId = sender == uid ? receiver : sender;
        
        if (!convosMap.containsKey(otherId)) {
          otherUserIds.add(otherId);
          convosMap[otherId] = {
            'other_user_id': otherId,
            'userId1': uid,
            'userId2': otherId,
            'last_message': msg['content'] ?? 'Image',
            'last_message_time': msg['created_at'],
            'unread_count': 0,
          };
        }
        if (msg['receiver_id'].toString().trim() == uid && 
            msg['status'] != 'read') {
          convosMap[otherId]!['unread_count'] = (convosMap[otherId]!['unread_count'] as int) + 1;
        }
      }

      if (otherUserIds.isNotEmpty) {
        final profilesMap = await _getUserProfiles(otherUserIds);
        for (var otherId in convosMap.keys) {
          final profile = profilesMap[otherId];
          convosMap[otherId]!['other_user_name'] = profile?['name'] ?? 'User ${otherId.substring(0, 4)}';
          convosMap[otherId]!['other_user_image'] = profile?['image'];
        }
      }

      return convosMap.values.map((c) => ChatConversationModel.fromMap(c, currentUserId: uid)).toList();
    } catch (e) {
      return [];
    }
  }

  // Delete all conversations for a user
  Future<void> deleteAllConversations(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) {
      debugPrint('ChatService: Cannot delete all conversations, userId is empty.');
      return;
    }

    try {
      debugPrint('ChatService: PERMANENTLY deleting all messages for user $uid');
      
      // Separate calls to ensure all messages are caught regardless of role
      await _supabase.from('messages').delete().eq('sender_id', uid);
      await _supabase.from('messages').delete().eq('receiver_id', uid);
          
      debugPrint('ChatService: Successfully deleted all messages for user $uid');
    } catch (e) {
      debugPrint('ChatService: Failed to delete all conversations: $e');
      throw Exception('Failed to delete all conversations: $e');
    }
  }

  // Delete a specific message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _supabase.from('messages').delete().eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  // Edit a specific message
  Future<void> editMessage(String messageId, String newContent) async {
    try {
      await _supabase.from('messages').update({
        'content': newContent,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', messageId);
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  String getConversationId(String userId1, String userId2) {
    final sortedIds = [userId1.trim(), userId2.trim()]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }
}
