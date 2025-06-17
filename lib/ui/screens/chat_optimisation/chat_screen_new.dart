// ignore_for_file: always_put_required_named_parameters_first

import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:ebroker/ui/screens/chat_optimisation/chat_app_bar.dart';
import 'package:ebroker/ui/screens/chat_optimisation/chat_helpers.dart';
import 'package:ebroker/ui/screens/chat_optimisation/chat_input_bar.dart';
import 'package:ebroker/ui/screens/chat_optimisation/message_renderer.dart';
import 'package:ebroker/ui/screens/chat_optimisation/registerar.dart';
import 'package:flutter/material.dart';

int totalMessageCount = 0;

ValueNotifier<bool> showDeletebutton = ValueNotifier<bool>(false);

ValueNotifier<int> selectedMessageid = ValueNotifier<int>(-5);
ValueNotifier<int> selectedRecieverId = ValueNotifier<int>(-5);

class ChatScreenNew extends StatefulWidget {
  const ChatScreenNew({
    super.key,
    required this.profilePicture,
    required this.userName,
    required this.propertyImage,
    required this.proeprtyTitle,
    required this.userId,
    required this.propertyId,
    required this.isBlockedByMe,
    required this.isBlockedByUser,
    this.from,
  });

  final String? from;
  final String profilePicture;
  final String userName;
  final String propertyImage;
  final String proeprtyTitle;
  final String userId;
  final String propertyId;
  final bool isBlockedByMe;
  final bool isBlockedByUser;

  @override
  State<ChatScreenNew> createState() => _ChatScreenNewState();
}

class _ChatScreenNewState extends State<ChatScreenNew>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _reasonController = TextEditingController();

  late final Stream<PermissionStatus> _notificationStream;
  late final StreamSubscription<dynamic> _notificationSubscription;
  StreamSubscription<dynamic>? _chatNotificationSubscription; // Add this line
  bool isNotificationPermissionGranted = true;
  bool? isBlockedByMe;
  bool? isBlockedByUser;

  // Variables for scroll handling
  bool _isScrolling = false;
  Timer? _scrollDebouncer;

  @override
  void initState() {
    super.initState();
    ChatMessageHandler.handle();
    _setupScrollListener();
    _fetchInitialMessages();
    _listenToNotificationPermission();
    _setupChatNotificationListener();

    // Set this as the active chat to prevent notifications
    NotificationService.setActiveChat(widget.userId, widget.propertyId);

    isBlockedByMe = widget.isBlockedByMe;
    isBlockedByUser = widget.isBlockedByUser;

    // Ensure we have a context for message rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ChatMessageHandler.messageContext = context;
        // Initialize visible audio messages after the UI is built
        _handleVisibleAudioMessages();
      }
    });
  }

  void _setupChatNotificationListener() {
    _chatNotificationSubscription =
        NotificationService.chatMessageStream.listen((messageData) {
      // Check if this notification is for the current chat
      final senderId = messageData['sender_id']?.toString() ?? '';
      final propertyId = messageData['property_id']?.toString() ?? '';
      final message = messageData['message']?.toString() ?? '';
      final file = messageData['file']?.toString() ?? '';
      final audio = messageData['audio']?.toString() ?? '';

      // Determine message type based on file extension if present
      var messageType = messageData['chat_message_type']?.toString() ?? 'text';

      // Override message type for image files
      if (file.isNotEmpty) {
        final fileExt = file.split('.').last.toLowerCase();
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(fileExt)) {
          messageType = 'image';
        }
      }

      if (senderId == widget.userId && propertyId == widget.propertyId) {
        // Create a new message from the notification data
        final newMessage = ChatMessage()
          ..id = DateTime.now().millisecondsSinceEpoch.toString()
          ..message = message
          ..chatMessageType = messageType
          ..senderId = senderId
          ..receiverId = HiveUtils.getUserId().toString()
          ..propertyId = propertyId
          ..file = file
          ..audio = audio
          ..setIsSentByMe(
            value: false,
          ) // Messages from notifications are from others
          ..date = messageData['created_at']?.toString() ??
              DateTime.now().toIso8601String()
          ..timeAgo = messageData['time_ago']?.toString() ?? '1s before';

        // Add the message to the handler
        ChatMessageHandler.add(newMessage);

        // Force refresh the handler messages
        ChatMessageHandler.refreshMessages();

        // Force UI update
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          context.read<LoadChatMessagesCubit>().hasMoreChat()) {
        // Pause any playing audio before loading more messages to prevent UI stuttering
        // ChatHelpers.stopAllAudio();
        // Start loading animation
        _startLoadingAnimation();
        // Load more messages
        context.read<LoadChatMessagesCubit>().loadMore();
      }

      // Check if scrolling has stopped to preload visible audio messages
      if (!_isScrolling) {
        _isScrolling = true;
        _scrollDebouncer?.cancel();
        _scrollDebouncer = Timer(const Duration(milliseconds: 300), () {
          _isScrolling = false;
          // Preload visible audio messages after scrolling stops
          _handleVisibleAudioMessages();
        });
      }
    });
  }

  void _fetchInitialMessages() {
    context.read<LoadChatMessagesCubit>().load(
          userId: int.parse(widget.userId),
          propertyId: int.parse(widget.propertyId),
        );
  }

  void _listenToNotificationPermission() {
    _notificationStream = _notificationPermissionLoop();
    _notificationSubscription =
        _notificationStream.listen((PermissionStatus status) {
      setState(() {
        isNotificationPermissionGranted = status.isGranted;
      });
    });
  }

  Stream<PermissionStatus> _notificationPermissionLoop() async* {
    while (true) {
      await Future<dynamic>.delayed(const Duration(seconds: 5));
      yield* Permission.notification.request().asStream();
    }
  }

  // Add these variables to the class
  bool _showLoadingAnimation = false;
  Timer? _loadingAnimationTimer;

  bool _shouldShowLoadingAnimation() {
    return _showLoadingAnimation;
  }

  // Add this method to start the animation
  void _startLoadingAnimation() {
    setState(() {
      _showLoadingAnimation = true;
    });

    // Cancel any existing timer
    _loadingAnimationTimer?.cancel();

    // Set a timer to hide the animation after it completes
    _loadingAnimationTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showLoadingAnimation = false;
        });
      }
    });
  }

  // Add this method to handle audio messages when they come into view
  void _handleVisibleAudioMessages() {
    // Add a post-frame callback to initialize audio players for visible messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        // Use the current message list to find visible audio messages
        final visibleMessages = ChatMessageHandler.getMessages();

        // Find audio messages in the visible area and preload them
        for (final message in visibleMessages) {
          if (message.chatMessageType == 'audio' &&
              message.audio != null &&
              message.audio!.isNotEmpty) {
            // Only preload a few audio files to avoid overwhelming the system
            if (visibleMessages.indexOf(message) < 5) {
              // Use a slight delay between preloads to avoid overwhelming the network
              Future.delayed(
                Duration(milliseconds: 500 * visibleMessages.indexOf(message)),
                () {
                  if (mounted) {
                    ChatHelpers.preloadAudio(message.id, message.audio!);
                  }
                },
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Error handling visible audio messages: $e');
      }
    });
  }

  @override
  void dispose() {
    _loadingAnimationTimer?.cancel();
    _scrollController.dispose();
    _reasonController.dispose();
    _notificationSubscription.cancel();
    _chatNotificationSubscription?.cancel();
    _scrollDebouncer?.cancel();

    // Stop all audio playback when leaving the screen
    // ChatHelpers.stopAllAudio();
    // Clear active chat when leaving the screen
    clearChatMessages();
    super.dispose();
  }

  Future<void> _handleAppBarAction(String value) async {
    await ChatHelpers.handleAppBarAction(
      context,
      value,
      widget.userId,
      widget.propertyId,
      _reasonController,
      (isBlocked) {
        setState(() {
          isBlockedByMe = isBlocked;
        });
      },
    );
  }

  Future<void> clearChatMessages() async {
    Future.delayed(Duration.zero, () {
      NotificationService.clearActiveChat();
      // Stop all audio playback before clearing messages
      // ChatHelpers.stopAllAudio();
      ChatMessageHandler.flush();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (mounted) {
          Navigator.pop(context);
          await context.read<GetChatListCubit>().fetch(forceRefresh: true);
        }
        // First clean up resources
        await clearChatMessages();
        await _notificationSubscription.cancel();
        await _chatNotificationSubscription?.cancel();
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SendMessageCubit()),
          BlocProvider(create: (_) => DeleteMessageCubit()),
        ],
        child: Builder(
          builder: (context) {
            return BlocListener<SendMessageCubit, SendMessageState>(
              listener: (context, state) {
                if (state is SendMessageSuccess) {
                  // Refresh messages when a new message is sent
                  _fetchInitialMessages();
                } else if (state is SendMessageFailed) {
                  // Show error message
                  HelperUtils.showSnackBarMessage(
                    context,
                    'Failed to send message: ${state.error}',
                  );
                }
              },
              child: Scaffold(
                appBar: ChatAppBar(
                  profilePicture: widget.profilePicture,
                  userName: widget.userName,
                  propertyTitle: widget.proeprtyTitle,
                  propertyImage: widget.propertyImage,
                  isBlockedByMe: isBlockedByMe ?? false,
                  isBlockedByUser: isBlockedByUser ?? false,
                  isNotificationPermissionGranted:
                      isNotificationPermissionGranted,
                  userId: widget.userId,
                  propertyId: widget.propertyId,
                  onMenuSelected: _handleAppBarAction,
                  isFrom: widget.from ?? 'chat_list',
                ),
                backgroundColor: context.color.primaryColor,
                body: Stack(
                  children: [
                    Image.asset(
                      'assets/chat_background/doodle.png',
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                    Column(
                      children: [
                        Expanded(
                          child: _buildChatList(context),
                        ),
                        if (isBlockedByMe ?? false)
                          _buildBlockedBanner(
                            'blockedByMe'.translate(context),
                          )
                        else if (isBlockedByUser ?? false)
                          _buildBlockedBanner(
                            'blockedByUser'.translate(context),
                          )
                        else
                          ChatInputBar(
                            receiverId: widget.userId,
                            propertyId: widget.propertyId,
                            scrollController: _scrollController,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlockedBanner(String text) {
    return ChatHelpers.buildBlockedBanner(context, text);
  }

  Widget _buildChatList(BuildContext context) {
    return BlocListener<LoadChatMessagesCubit, LoadChatMessagesState>(
      listener: (context, state) {
        if (state is LoadChatMessagesSuccess) {
          ChatMessageHandler.fillMessages(state.messages);
          // Optionally, handle audio preloading or setState if needed
        }
      },
      child: StreamBuilder<List<ChatMessage>>(
        stream: ChatMessageHandler.listenMessages(),
        builder: (context, snapshot) {
          final messages = snapshot.data ?? [];
          if (context.read<LoadChatMessagesCubit>().state
              is LoadChatMessagesInProgress) {
            return ChatHelpers.buildChatShimmer(context, _scrollController);
          }
          if (messages.isEmpty) {
            return const SizedBox.shrink();
          }
          return Stack(
            children: [
              ListView(
                physics: Constant.scrollPhysics,
                padding: const EdgeInsets.symmetric(vertical: 16),
                controller: _scrollController,
                reverse: true,
                children: MessageRenderUtils.groupMessagesByDate(
                  context,
                  messages,
                ),
              ),
              if (_shouldShowLoadingAnimation())
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.color.backgroundColor,
                          context.color.backgroundColor.withValues(alpha: 0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.color.tertiaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
