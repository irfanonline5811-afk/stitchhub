import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/modern_ui_components.dart';
import '../../theme/app_theme.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.user != null) {
      await chatProvider.loadConversations(authProvider.user!.id);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  Future<void> _showDeleteAllDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          title: const Text('Clear All Chats'),
          content: const Text('Are you sure you want to delete all your conversations? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.error,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      if (authProvider.user != null) {
        try {
          await chatProvider.deleteAllConversations(authProvider.user!.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All chats cleared'),
                backgroundColor: AppTheme.success,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to clear chats'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear All Chats',
            onPressed: () => _showDeleteAllDialog(),
          ),
        ],
        elevation: 0,
      ),
      body: Consumer2<ChatProvider, AuthProvider>(
        builder: (context, chatProvider, authProvider, child) {
          if (chatProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
              ),
            );
          }

          if (chatProvider.error != null) {
            return ModernEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Error Loading Messages',
              subtitle: chatProvider.error,
              buttonText: 'Retry',
              onButtonTap: _loadConversations,
            );
          }

          if (chatProvider.conversations.isEmpty) {
            return const ModernEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No Conversations Yet',
              subtitle: 'Tailor se message karo, yahan dikhega',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadConversations,
            color: AppTheme.primaryGreen,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              itemCount: chatProvider.conversations.length,
              itemBuilder: (context, index) {
                final conversation = chatProvider.conversations[index];
                final currentUserId = authProvider.user?.id ?? '';
                
                // Determine the other user's info
                final isCurrentUserFirst = conversation.userId1 == currentUserId;
                final otherUserId = isCurrentUserFirst ? conversation.userId2 : conversation.userId1;
                final otherUserName = isCurrentUserFirst ? conversation.userName2 : conversation.userName1;
                final otherUserImageUrl = isCurrentUserFirst ? conversation.user2ImageUrl : conversation.user1ImageUrl;

                return AnimatedFadeIn(
                  delay: index * 0.1,
                  child: Dismissible(
                    key: Key(conversation.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.error,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppTheme.white,
                        size: 28,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                            title: const Text('Delete Chat'),
                            content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.error,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) async {
                      try {
                        await chatProvider.deleteConversation(currentUserId, otherUserId, currentUserId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Chat deleted'),
                              backgroundColor: AppTheme.success,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Failed to delete chat'),
                              backgroundColor: AppTheme.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          _loadConversations(); // Reload to restore the item
                        }
                      }
                    },
                    child: ModernCard(
                      onTap: () async {
                        if (authProvider.user != null) {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(
                                otherUserId: otherUserId,
                                otherUserName: otherUserName ?? 'Unknown',
                                otherUserImageUrl: otherUserImageUrl,
                              ),
                            ),
                          );
                          // Wait for DB update to finish
                          await Future.delayed(const Duration(milliseconds: 500));
                          _loadConversations();
                        }
                      },
                      onLongPress: () async {
                        final bool? shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              ),
                              title: const Text('Delete Chat'),
                              content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.error,
                                  ),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );

                        if (shouldDelete == true) {
                          try {
                            await chatProvider.deleteConversation(currentUserId, otherUserId, currentUserId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Chat deleted'),
                                  backgroundColor: AppTheme.success,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Failed to delete chat'),
                                  backgroundColor: AppTheme.error,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              _loadConversations();
                            }
                          }
                        }
                      },
                      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: otherUserImageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                                  child: Image.network(
                                    otherUserImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person_rounded,
                                        size: 28,
                                        color: AppTheme.white,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  size: 28,
                                  color: AppTheme.white,
                                ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      otherUserName ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.gray900,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(conversation.lastMessageTime),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.gray600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      conversation.lastMessage,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: conversation.unreadCount > 0 ? AppTheme.gray900 : AppTheme.gray700,
                                        fontWeight: conversation.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (conversation.unreadCount > 0)
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryGreen,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${conversation.unreadCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

