import 'package:ebroker/data/repositories/chat_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:ebroker/ui/screens/chat_optimisation/message_renderer.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Helper class for chat-related utility functions
class ChatHelpers {
  // Audio MIME types mapping - keeping for reference only

  /// List of supported image types
  static final List<String> supportedImageTypes = [
    'jpeg',
    'jpg',
    'png',
  ];

  /// Get message type based on content
  static String getMessageType(
    String? audioPath,
    String? message,
    String? file,
  ) {
    return MessageRenderUtils.getMessageType(audioPath, message, file);
  }

  /// Create a chat message object
  static ChatMessage createChatMessage({
    required String message,
    required String receiverId,
    required String propertyId,
    String? file,
    String? audio,
    String? audioPath,
  }) {
    return MessageRenderUtils.createChatMessage(
      message: message,
      receiverId: receiverId,
      propertyId: propertyId,
      file: file,
      audio: audio,
      audioPath: audioPath,
    );
  }

  /// Format a date key for display in chat timeline
  static String formatDateKey(String dateKey) {
    return MessageRenderUtils.formatDateKey(dateKey);
  }

  /// Get a date key for grouping messages
  static String getDateKey(DateTime date) {
    return MessageRenderUtils.getDateKey(date);
  }

  /// Compare date keys for sorting
  static int compareDateKeys(String a, String b) {
    return MessageRenderUtils.compareDateKeys(a, b);
  }

  /// Get month name from month number
  static String getMonthName(int month) {
    return MessageRenderUtils.getMonthName(month);
  }

  /// Build a date divider widget for chat timeline
  static Widget buildDateDivider(BuildContext context, String dateKey) {
    return MessageRenderUtils.buildDateDivider(context, dateKey);
  }

  /// Build a blocked banner widget
  static Widget buildBlockedBanner(BuildContext context, String text) {
    return Container(
      width: double.infinity,
      height: kBottomNavigationBarHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.color.primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CustomText(text, textAlign: TextAlign.center),
    );
  }

  /// Group messages by date and create a list of widgets with date dividers
  static List<Widget> groupMessagesByDate(
    BuildContext context,
    List<ChatMessage> messages,
  ) {
    return MessageRenderUtils.groupMessagesByDate(context, messages);
  }

  /// Build a message bubble widget
  static Widget buildMessageBubble(
    ChatMessage message,
  ) {
    // Use the UnifiedMessageRenderer instead
    return UnifiedMessageRenderer(message: message);
  }

  /// Build a chat shimmer loading widget
  static Widget buildChatShimmer(
    BuildContext context,
    ScrollController scrollController,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      controller: scrollController,
      physics: Constant.scrollPhysics,
      reverse: true,
      itemCount: 25,
      itemBuilder: (context, index) {
        final isSentByMe = index.isEven;
        // Generate random widths to create a more realistic chat appearance
        final width = context.screenWidth * (0.3 + (index % 3 * 0.1));

        return Align(
          alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            height: 30 + (index % 2 * 10), // Vary height slightly
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            width: width,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isSentByMe ? 16 : 4),
                bottomRight: Radius.circular(isSentByMe ? 4 : 16),
              ),
              child: const CustomShimmer(
                borderRadius: 0,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handle app bar actions
  static Future<void> handleAppBarAction(
    BuildContext context,
    String value,
    String userId,
    String propertyId,
    TextEditingController reasonController,
    Function(bool) updateBlockStatus,
  ) async {
    switch (value) {
      case 'agentDetails':
        await onTapAgentDetails(context, userId);
      case 'propertyDetails':
        await onTapPropertyDetails(context, userId, propertyId);
      case 'deleteAllMessages':
        await onTapDeleteAllMessages(context, userId, propertyId);
      case 'blockUser':
        await onTapBlockUser(
          context,
          userId,
          reasonController,
          updateBlockStatus,
        );
      case 'unblockUser':
        await onTapUnblockUser(context, userId, updateBlockStatus);
    }
  }

  /// Handle agent details tap
  static Future<void> onTapAgentDetails(
    BuildContext context,
    String userId,
  ) async {
    if (Constant.isDemoModeOn) {
      await HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'thisActionNotValidDemo'),
      );
      return;
    }

    await GuestChecker.check(
      onNotGuest: () async {
        await Navigator.pushNamed(
          context,
          Routes.agentDetailsScreen,
          arguments: {
            'agentID': userId,
            'isAdmin': userId == '0',
          },
        );
      },
    );
  }

  /// Handle property details tap
  static Future<void> onTapPropertyDetails(
    BuildContext context,
    String userId,
    String propertyId,
  ) async {
    try {
      unawaited(Widgets.showLoader(context));
      final data = await PropertyRepository().fetchPropertyFromPropertyId(
        id: int.parse(propertyId),
        isMyProperty: userId == HiveUtils.getUserId(),
      );
      Widgets.hideLoder(context);
      HelperUtils.goToNextPage(
        Routes.propertyDetails,
        context,
        false,
        args: {
          'propertyData': data,
          'fromMyProperty': userId == HiveUtils.getUserId(),
        },
      );
    } catch (e) {
      Widgets.hideLoder(context);
    }
  }

  /// Handle delete all messages tap
  static Future<void> onTapDeleteAllMessages(
    BuildContext context,
    String userId,
    String propertyId,
  ) async {
    if (Constant.isDemoModeOn) {
      await HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'thisActionNotValidDemo'),
      );
      return;
    }

    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        onAccept: () async {
          await context.read<DeleteMessageCubit>().delete(
                messageId: '',
                senderId: HiveUtils.getUserId() ?? '',
                receiverId: userId,
                propertyId: propertyId,
              );
          final deleteState = context.read<DeleteMessageCubit>().state;
          if (deleteState is DeleteMessageSuccess) {
            await context.read<GetChatListCubit>().fetch(forceRefresh: true);
            Navigator.pop(context);
            await HelperUtils.showSnackBarMessage(
              context,
              'messageDeleted'.translate(context),
            );
          } else {
            await HelperUtils.showSnackBarMessage(
              context,
              'failedToDeleteMessages'.translate(context),
            );
          }
        },
        title: 'areYouSure'.translate(context),
        content: CustomText('msgWillNotRecover'.translate(context)),
      ),
    );
  }

  /// Handle block user tap
  static Future<void> onTapBlockUser(
    BuildContext context,
    String userId,
    TextEditingController reasonController,
    Function(bool) updateBlockStatus,
  ) async {
    if (Constant.isDemoModeOn) {
      await HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'thisActionNotValidDemo'),
      );
      return;
    }

    await UiUtils.showBlurredDialoge(
      context,
      sigmaX: 0.5,
      sigmaY: 0.5,
      dialog: BlurredDialogBox(
        onAccept: () async {
          final response = await ChatRepository().blockUser(
            userId: userId,
            reason: reasonController.text,
          );
          if (response['error'] == true) {
            await HelperUtils.showSnackBarMessage(
              context,
              response['message']?.toString() ?? '',
            );
            return;
          }

          await context.read<GetChatListCubit>().fetch(forceRefresh: true);
          updateBlockStatus(true);
          await HelperUtils.showSnackBarMessage(
            context,
            UiUtils.translate(context, 'userBlocked'),
          );
        },
        title: 'areYouSure'.translate(context),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText('userWillBeBlocked'.translate(context)),
            const SizedBox(height: 10),
            CustomTextFormField(
              controller: reasonController,
              hintText: 'reasonOptional'.translate(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle unblock user tap
  static Future<void> onTapUnblockUser(
    BuildContext context,
    String userId,
    Function(bool) updateBlockStatus,
  ) async {
    if (Constant.isDemoModeOn) {
      await HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'thisActionNotValidDemo'),
      );
      return;
    }

    await UiUtils.showBlurredDialoge(
      context,
      sigmaX: 0.5,
      sigmaY: 0.5,
      dialog: BlurredDialogBox(
        onAccept: () async {
          final response = await ChatRepository().unblockUser(userId: userId);
          if (response['error'] == true) {
            await HelperUtils.showSnackBarMessage(
              context,
              response['message']?.toString() ?? '',
            );
            return;
          }

          await context.read<GetChatListCubit>().fetch(forceRefresh: true);
          updateBlockStatus(false);
          await HelperUtils.showSnackBarMessage(
            context,
            UiUtils.translate(context, 'userUnblocked'),
          );
        },
        title: 'areYouSure'.translate(context),
        content: CustomText('userWillBeUnblocked'.translate(context)),
      ),
    );
  }

  /// Pick a gallery attachment (image)
  static Future<void> pickGalleryAttachment(
    Function(PlatformFile) onPicked,
  ) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (picked != null && picked.files.isNotEmpty) {
      onPicked(picked.files.first);
    }
  }

  /// Pick a document attachment
  static Future<void> pickDocumentAttachment(
    Function(PlatformFile) onPicked,
  ) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (picked != null && picked.files.isNotEmpty) {
      onPicked(picked.files.first);
    }
  }

  // Audio attachment picking moved to ChatAudio class

  // Method to check if audio is playing for a specific message - delegates to AudioMessage
  static bool isAudioPlaying(String messageId) {
    // Use the AudioMessage implementation instead
    // Since we don't have direct access to the specific message instance here,
    // we just return false and let the AudioMessage instance handle its own state
    return false;
  }

  // Method to preload audio - delegates to AudioMessage
  static Future<void> preloadAudio(String messageId, String audioUrl) async {
    try {
      debugPrint('Preloading audio for message $messageId: $audioUrl');

      // Create a temporary audio player just for preloading
      final preloader = AudioPlayer();

      try {
        // Try to preload the audio
        // Use a timeout to prevent hanging
        await preloader.setUrl(audioUrl).timeout(
          const Duration(seconds: 8),
          onTimeout: () {
            debugPrint('Preload timed out for $messageId');
            throw TimeoutException('Preload timed out');
          },
        );

        debugPrint('Successfully preloaded audio for message $messageId');
      } catch (e) {
        debugPrint('Error preloading audio for message $messageId: $e');
      } finally {
        // Make sure to dispose the preloader
        await preloader.dispose();
      }
    } catch (e) {
      // Catch any exceptions in the outer block to prevent crashes
      debugPrint('Exception in preloadAudio: $e');
    }
  }
}
