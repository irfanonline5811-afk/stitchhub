import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/message_model.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import '../../theme/app_theme.dart';

class ChatDetailScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImageUrl;

  const ChatDetailScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImageUrl,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    // Configure global audio context for playback
    // ignore: prefer_const_constructors
    AudioPlayer.global.setAudioContext(AudioContext(
      // ignore: prefer_const_constructors
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      // ignore: prefer_const_constructors
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        // ignore: prefer_const_literals_to_create_immutables
        options: {
          AVAudioSessionOptions.defaultToSpeaker,
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    ));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final currentUserId = authProvider.user!.id;
      
      // Load messages
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.loadMessages(currentUserId, widget.otherUserId);
      
      // Mark messages as read
      chatProvider.markMessagesAsRead(currentUserId, widget.otherUserId, currentUserId);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Clear messages and cancel stream from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.clearMessages();
      chatProvider.cancelMessageStream();
    });
    _audioPlayer.dispose();
    super.dispose();
  }
  Future<void> _sendVoiceNote(String path) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.user != null) {
      try {
        // Here we would normally upload to Supabase Storage first
        // For now, let's assume we send a dummy URL or local path for demonstration
        final audioUrl = await chatProvider.uploadAudio(path);
        if (audioUrl == null) throw Exception('Upload failed');
        
        await chatProvider.sendMessage(
          senderId: authProvider.user!.id,
          receiverId: widget.otherUserId,
          senderName: authProvider.user!.name,
          receiverName: widget.otherUserName,
          content: audioUrl,
          type: MessageType.audio,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error sending voice note: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.user != null) {
      try {
        final content = _messageController.text.trim();
        _messageController.clear();
        _scrollToBottom();

        await chatProvider.sendMessage(
          senderId: authProvider.user!.id,
          receiverId: widget.otherUserId,
          senderName: authProvider.user!.name,
          receiverName: widget.otherUserName,
          content: content,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sending message: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.otherUserImageUrl != null
                  ? NetworkImage(widget.otherUserImageUrl!)
                  : null,
              child: widget.otherUserImageUrl == null
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUserName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoadingMessages && chatProvider.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (chatProvider.error != null && chatProvider.messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            chatProvider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _initializeChat,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final messages = chatProvider.messages;

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Scroll to bottom when new message arrives
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSent = message.senderId == currentUserId;

                    return message.type == MessageType.audio
                        ? _VoiceMessageBubble(
                            message: message,
                            isSent: isSent,
                            time: _formatTime(message.createdAt),
                            audioPlayer: _audioPlayer,
                            otherUserImageUrl: widget.otherUserImageUrl,
                          )
                        : _MessageBubble(
                            message: message,
                            isSent: isSent,
                            time: _formatTime(message.createdAt),
                            otherUserImageUrl: widget.otherUserImageUrl,
                          );
                  },
                );
              },
            ),
          ),
          // Message Input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SocialMediaRecorder(
                      sendRequestFunction: (soundFile, time) {
                        _sendVoiceNote(soundFile.path);
                      },
                      encode: AudioEncoderType.AAC,
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF2E7D32),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSent;
  final String time;
  final String? otherUserImageUrl;

  const _MessageBubble({
    required this.message,
    required this.isSent,
    required this.time,
    this.otherUserImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: isSent ? () => _showActionMenu(context) : null,
        child: Row(
          mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSent) ...[
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[300],
                backgroundImage: otherUserImageUrl != null ? NetworkImage(otherUserImageUrl!) : null,
                child: otherUserImageUrl == null ? const Icon(Icons.person, size: 14, color: Colors.grey) : null,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSent
                      ? const Color(0xFF2E7D32)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isSent ? 16 : 4),
                    bottomRight: Radius.circular(isSent ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isSent ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            color: isSent
                                ? Colors.white.withValues(alpha: 0.7)
                                : Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        if (isSent) ...[
                          const SizedBox(width: 4),
                          Icon(
                            message.isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: message.isRead
                                ? Colors.blue[300]
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isSent) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit Message'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: const Text('Delete Message', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new message'),
          maxLines: null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                await chatProvider.updateMessage(message.id, controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              await chatProvider.deleteMessage(message.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _VoiceMessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isSent;
  final String time;
  final AudioPlayer audioPlayer;
  final String? otherUserImageUrl;

  const _VoiceMessageBubble({
    required this.message,
    required this.isSent,
    required this.time,
    required this.audioPlayer,
    this.otherUserImageUrl,
  });

  @override
  State<_VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<_VoiceMessageBubble> {
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await widget.audioPlayer.pause();
        if (mounted) setState(() => _isPlaying = false);
      } else {
        // Reset player before starting new audio
        await widget.audioPlayer.stop();
        await widget.audioPlayer.setVolume(1.0);
        
        // Listeners for this specific playback session
        _playerCompleteSubscription?.cancel();
        _playerCompleteSubscription = widget.audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _position = Duration.zero;
            });
          }
        });

        _durationSubscription?.cancel();
        _durationSubscription = widget.audioPlayer.onDurationChanged.listen((d) {
          if (mounted) setState(() => _duration = d);
        });

        _positionSubscription?.cancel();
        _positionSubscription = widget.audioPlayer.onPositionChanged.listen((p) {
          if (mounted) setState(() => _position = p);
        });

        debugPrint('Playing voice note from: ${widget.message.content}');
        
        Source source;
        if (widget.message.content.startsWith('http')) {
          source = UrlSource(widget.message.content);
        } else {
          source = DeviceFileSource(widget.message.content);
        }

        await widget.audioPlayer.play(source);
        if (mounted) setState(() => _isPlaying = true);
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: widget.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isSent) ...[
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.otherUserImageUrl != null ? NetworkImage(widget.otherUserImageUrl!) : null,
              child: widget.otherUserImageUrl == null ? const Icon(Icons.person, size: 14, color: Colors.grey) : null,
            ),
            const SizedBox(width: 8),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSent ? const Color(0xFF2E7D32) : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: widget.isSent ? Colors.white : Colors.black87,
                  ),
                  onPressed: _togglePlayback,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (widget.isSent ? Colors.white : Colors.grey[400])!.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _duration.inMilliseconds > 0 
                            ? _position.inMilliseconds / _duration.inMilliseconds 
                            : 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.isSent ? Colors.white : AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.time,
                      style: TextStyle(
                        fontSize: 10,
                        color: (widget.isSent ? Colors.white : Colors.grey[600])!.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.mic, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
