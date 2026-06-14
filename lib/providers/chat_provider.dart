import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../utils/network_utils.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<ChatConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isLoadingMessages = false;
  String? _error;
  String? _currentConversationId;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _conversationsSubscription;

  // Safety Vault (Local Blacklist)
  List<String> _blacklistedOtherUserIds = [];
  
  // Cache to remember chats we've just read to prevent "jump back" (Persistent)
  Map<String, DateTime> _recentlyReadChats = {};
  bool _isLocalDataLoaded = false;

  ChatProvider() {
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    if (_isLocalDataLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Blacklist
      _blacklistedOtherUserIds = prefs.getStringList('blacklisted_chats') ?? [];
      
      // Load Recently Read Cache
      final readData = prefs.getString('recently_read_chats');
      if (readData != null) {
        final Map<String, dynamic> decoded = jsonDecode(readData);
        _recentlyReadChats = decoded.map((key, value) => 
          MapEntry(key, DateTime.parse(value as String)));
      }
      
      _isLocalDataLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider: Failed to load local data: $e');
    }
  }

  Future<void> _saveBlacklist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('blacklisted_chats', _blacklistedOtherUserIds);
    } catch (e) {
      debugPrint('ChatProvider: Failed to save blacklist: $e');
    }
  }

  Future<void> _saveReadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_recentlyReadChats.map((key, value) => 
        MapEntry(key, value.toIso8601String())));
      await prefs.setString('recently_read_chats', encoded);
    } catch (e) {
      debugPrint('ChatProvider: Failed to save read cache: $e');
    }
  }

  List<ChatConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isLoadingMessages => _isLoadingMessages;
  String? get error => _error;
  String? get currentConversationId => _currentConversationId;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingMessages(bool loading) {
    _isLoadingMessages = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }


  // Load all conversations for a user with real-time updates
  Future<void> loadConversations(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty || uid == 'null') {
      _conversations = [];
      _setError(null);
      notifyListeners();
      return;
    }

    // MANDATORY: Wait for local data (blacklist/read-cache) before doing anything else
    if (!_isLocalDataLoaded) {
      await _loadLocalData();
    }

    // Stop existing subscription
    await _conversationsSubscription?.cancel();

    try {
      _setLoading(true);
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      // Initial load with blacklist & recently read filters
      final rawConversations = await _chatService.getConversations(uid);
      _conversations = _filterAndSyncConversations(rawConversations, uid);
      
      // Cache results
      await LocalStorageService().saveData(
          'conversations', _conversations.map((e) => e.toMap()).toList(), userId: uid);

      _setLoading(false);
      notifyListeners();

      // Start stream
      _conversationsSubscription = _chatService.streamConversations(uid).listen(
        (updatedConvos) async {
          _conversations = _filterAndSyncConversations(updatedConvos, uid);
          await LocalStorageService().saveData(
              'conversations', _conversations.map((e) => e.toMap()).toList(), userId: uid);
          notifyListeners();
        },
        onError: (e) {
          debugPrint('ChatProvider: Stream Error: $e');
        }
      );
    } catch (e) {
      debugPrint('ChatProvider: Error loading conversations, checking cache. Error: $e');
      final cached = LocalStorageService().getData('conversations', userId: uid);
      if (cached != null && cached is List) {
        _conversations = cached.map((c) => ChatConversationModel.fromMap(c, currentUserId: uid)).toList();
        _setError('Working offline. Showing cached conversations.');
      } else {
        _setError(e.toString());
      }
      _setLoading(false);
    }
  }

  // Helper to filter by blacklist and force 0 unread for recently read chats
  List<ChatConversationModel> _filterAndSyncConversations(List<ChatConversationModel> convos, String currentUid) {
    return convos.where((c) {
      final otherId = (c.userId1.trim() == currentUid ? c.userId2 : c.userId1).trim();
      return !_blacklistedOtherUserIds.contains(otherId);
    }).map((c) {
      final otherId = (c.userId1.trim() == currentUid ? c.userId2 : c.userId1).trim();
      
      // If we recently read this chat (within last 30 seconds), force count to 0
      // unless a NEWER message has arrived since then
      if (_recentlyReadChats.containsKey(otherId)) {
        final lastReadTime = _recentlyReadChats[otherId]!;
        if (c.lastMessageTime.isBefore(lastReadTime) || c.lastMessageTime.isAtSameMomentAs(lastReadTime)) {
          return c.copyWith(unreadCount: 0);
        } else {
          // A genuinely new message arrived after we marked as read
          _recentlyReadChats.remove(otherId);
        }
      }
      return c;
    }).toList();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _conversationsSubscription?.cancel();
    super.dispose();
  }

  // Load messages for a conversation
  Future<void> loadMessages(String userId1, String userId2) async {
    final uid1 = userId1.trim();
    final uid2 = userId2.trim();

    if (uid1.isEmpty || uid2.isEmpty || uid1 == 'null' || uid2 == 'null') {
      _messages = [];
      _setError(null);
      notifyListeners();
      return;
    }
    
    // Stop any existing subscription
    await _messagesSubscription?.cancel();
    
    try {
      _setLoadingMessages(true);
      _setError(null);

      _currentConversationId = _chatService.getConversationId(uid1, uid2);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }
      
      // Load initial messages
      final messages = await _chatService.getMessages(uid1, uid2);
      _messages = messages;

      // Cache messages
      final convoId = _currentConversationId!;
      await LocalStorageService().saveData('messages_$convoId', _messages.map((e) => e.toMap()).toList());

      _setLoadingMessages(false);
      notifyListeners();

      // Subscribe to real-time updates
      _messagesSubscription = _chatService.streamMessages(uid1, uid2).listen(
        (updatedMessages) async {
          _messages = updatedMessages;
          _setError(null);
          
          final convoId = _chatService.getConversationId(uid1, uid2);
          await LocalStorageService().saveData('messages_$convoId', _messages.map((e) => e.toMap()).toList());
          
          // If we are currently in this chat, mark any new incoming messages as read
          final hasUnread = updatedMessages.any((m) => m.receiverId == uid1 && !m.isRead);
          if (hasUnread) {
            markMessagesAsRead(uid1, uid2, uid1);
          } else {
            notifyListeners();
          }
        },
        onError: (err) {
          debugPrint('ChatProvider: Live Screen Stream Error: $err');
          // Silently handle stream errors but keep showing local messages
        },
      );
    } catch (e) {
      debugPrint('ChatProvider: Error loading messages, checking cache. Error: $e');
      final convoId = _chatService.getConversationId(uid1, uid2);
      final cached = LocalStorageService().getData('messages_$convoId');
      if (cached != null && cached is List) {
        _messages = cached.map((e) => MessageModel.fromMap(e)).toList();
        _setError('Working offline. Showing cached messages.');
      } else {
        _setError(e.toString());
      }
      _setLoadingMessages(false);
    }
  }

  // Cancel stream when leaving chat
  Future<void> cancelMessageStream() async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  // Upload audio
  Future<String?> uploadAudio(String path) async {
    return await _chatService.uploadAudio(path);
  }

  // Send a message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String senderName,
    required String receiverName,
    required String content,
    String? orderId,
    MessageType type = MessageType.text,
    String? localAudioPath,
  }) async {
    try {
      _setError(null);

      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _chatService.sendMessage(
        senderId: senderId,
        receiverId: receiverId,
        senderName: senderName,
        receiverName: receiverName,
        content: content,
        orderId: orderId,
        type: type,
      );
    } catch (e) {
      debugPrint('ChatProvider: sendMessage failed, queueing offline. Error: $e');

      // Create temporary message for optimistic UI
      final tempMessageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';
      final tempMessage = MessageModel(
        id: tempMessageId,
        senderId: senderId,
        receiverId: receiverId,
        senderName: senderName,
        receiverName: receiverName,
        content: content,
        orderId: orderId,
        type: type,
        isRead: false,
        createdAt: DateTime.now(),
      );

      _messages.add(tempMessage);
      notifyListeners();

      // Save to cache
      final convoId = _chatService.getConversationId(senderId, receiverId);
      await LocalStorageService().saveData('messages_$convoId', _messages.map((e) => e.toMap()).toList());

      // Queue offline sync action
      await SyncService().queueAction('send_message', {
        'senderId': senderId,
        'receiverId': receiverId,
        'senderName': senderName,
        'receiverName': receiverName,
        'content': content,
        'orderId': orderId,
        'type': type.name,
        'localAudioPath': localAudioPath,
      });

      _setError('Working offline. Message queued.');
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String userId1, String userId2, String currentUserId) async {
    if (userId1.isEmpty || userId2.isEmpty || currentUserId.isEmpty) return;
    
    try {
      final otherUserId = (userId1.trim() == currentUserId.trim() ? userId2 : userId1).trim();
      
      // 1. Immediate Local UI Update (Clean & Fast)
      _recentlyReadChats[otherUserId] = DateTime.now(); // Lock the badge at 0
      await _saveReadCache(); // Save to phone memory
      
      final convIndex = _conversations.indexWhere((c) => 
        (c.userId1.trim() == currentUserId.trim() && c.userId2.trim() == otherUserId) ||
        (c.userId1.trim() == otherUserId && c.userId2.trim() == currentUserId.trim())
      );

      if (convIndex != -1) {
        _conversations[convIndex] = _conversations[convIndex].copyWith(unreadCount: 0);
        notifyListeners();
      }

      // 2. Perform Database Update
      await _chatService.markMessagesAsRead(userId1, userId2, currentUserId);
      
      // 3. Local Message Update
      if (_currentConversationId == _chatService.getConversationId(userId1, userId2)) {
        for (var i = 0; i < _messages.length; i++) {
          if (_messages[i].receiverId.trim() == currentUserId.trim()) {
            _messages[i] = _messages[i].copyWith(isRead: true);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ChatProvider: Failed to mark as read: $e');
    }
  }

  // Delete a conversation
  Future<void> deleteConversation(String userId1, String userId2, String currentUserId) async {
    final otherUserId = (userId1.trim() == currentUserId.trim() ? userId2 : userId1).trim();
    
    try {
      // 1. Permanently add to local blacklist (Safety Vault)
      if (!_blacklistedOtherUserIds.contains(otherUserId)) {
        _blacklistedOtherUserIds.add(otherUserId);
        await _saveBlacklist(); // Save to phone memory
      }
      
      // 2. Optimistic Update: Remove from list immediately
      _conversations.removeWhere((c) => 
        (c.userId1.trim() == currentUserId.trim() && c.userId2.trim() == otherUserId) ||
        (c.userId1.trim() == otherUserId && c.userId2.trim() == currentUserId.trim())
      );
      notifyListeners();

      // 3. Perform the Hard Delete on Server
      await _chatService.deleteConversation(userId1, userId2);
      
      // 4. Verify and clean up
      await Future.delayed(const Duration(milliseconds: 500));
      await loadConversations(currentUserId);
      
    } catch (e) {
      debugPrint('ChatProvider: Delete failed, but kept blacklisted: $e');
    }
  }

  // Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _chatService.deleteMessage(messageId);
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();
    } catch (e) {
      debugPrint('ChatProvider: deleteMessage failed, queueing offline. Error: $e');

      // Optimistic delete
      _messages.removeWhere((m) => m.id == messageId);
      notifyListeners();

      // Save to cache
      if (_currentConversationId != null) {
        await LocalStorageService().saveData('messages_$_currentConversationId', _messages.map((e) => e.toMap()).toList());
      }

      // Queue action
      await SyncService().queueAction('delete_message', {
        'messageId': messageId,
      });
      _setError('Working offline. Message deletion queued.');
    }
  }

  // Update/Edit a message
  Future<void> updateMessage(String messageId, String newContent) async {
    try {
      final isOnline = await NetworkUtils.checkConnectivity();
      if (!isOnline) {
        throw TimeoutException('Offline mode');
      }

      await _chatService.editMessage(messageId, newContent);
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(content: newContent);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('ChatProvider: updateMessage failed, queueing offline. Error: $e');

      // Optimistic update
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(content: newContent);
        notifyListeners();
      }

      // Save to cache
      if (_currentConversationId != null) {
        await LocalStorageService().saveData('messages_$_currentConversationId', _messages.map((e) => e.toMap()).toList());
      }

      // Queue action
      await SyncService().queueAction('edit_message', {
        'messageId': messageId,
        'newContent': newContent,
      });
      _setError('Working offline. Message edit queued.');
    }
  }

  // Clear messages
  void clearMessages() {
    _messages = [];
    _currentConversationId = null;
    _setError(null);
    notifyListeners();
  }

  // Refresh conversations
  Future<void> refreshConversations(String userId) async {
    await loadConversations(userId);
  }

  // Delete all conversations for a user
  Future<void> deleteAllConversations(String userId) async {
    try {
      _setLoading(true);
      await _chatService.deleteAllConversations(userId);
      _conversations.clear();
      _messages.clear();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      notifyListeners();
      rethrow;
    }
  }
}
