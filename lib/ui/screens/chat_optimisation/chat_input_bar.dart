import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_audio/widgets/chat_widget.dart';
import 'package:ebroker/ui/screens/chat/chat_audio/widgets/record_button.dart';
import 'package:ebroker/ui/screens/chat_optimisation/chat_helpers.dart';
import 'package:ebroker/ui/screens/chat_optimisation/message_renderer.dart';
import 'package:ebroker/ui/screens/chat_optimisation/registerar.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    required this.receiverId,
    required this.propertyId,
    required this.scrollController,
    super.key,
  });

  final String receiverId;
  final String propertyId;
  final ScrollController scrollController;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ValueNotifier<bool> _showRecordButton = ValueNotifier(true);
  PlatformFile? _attachment;
  late final AnimationController _recordAnimation;

  @override
  void initState() {
    super.initState();

    _recordAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _textController.addListener(() {
      _showRecordButton.value =
          _textController.text.trim().isEmpty && _attachment == null;
    });
  }

  @override
  void dispose() {
    _recordAnimation.dispose();
    _textController.dispose();
    _showRecordButton.dispose();
    super.dispose();
  }

  void _removeAttachment() {
    setState(() => _attachment = null);
    _showRecordButton.value = _textController.text.trim().isEmpty;
  }

  void _sendTextOrAttachment() {
    if (_textController.text.trim().isEmpty && _attachment == null) return;
    // Send to server using SendMessageCubit
    context.read<SendMessageCubit>().send(
          proeprtyId: widget.propertyId,
          recieverId: widget.receiverId,
          senderId: HiveUtils.getUserId().toString(),
          message: _textController.text.trim(),
          attachment: _attachment?.path,
        );

    _textController.clear();
    _removeAttachment();
    widget.scrollController.jumpTo(widget.scrollController.offset - 10);
  }

  void _sendAudio(String? path) {
    final model = MessageRenderUtils.createChatMessage(
      message: _textController.text.trim(),
      audio: path,
      receiverId: widget.receiverId,
      propertyId: widget.propertyId,
      audioPath: path,
    );

    // Add to local message handler for immediate display
    ChatMessageHandler.add(model);

    // Send to server using SendMessageCubit
    context.read<SendMessageCubit>().send(
          proeprtyId: widget.propertyId,
          recieverId: widget.receiverId,
          senderId: HiveUtils.getUserId().toString(),
          message: _textController.text.trim(),
          attachment: _attachment?.path,
          audio: path,
        );

    _textController.clear();
    widget.scrollController.jumpTo(widget.scrollController.offset - 10);
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: context.color.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              'selectAttachment'.translate(context),
              fontSize: context.font.larger,
              fontWeight: FontWeight.bold,
              color: context.color.textColorDark,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  context,
                  Icons.image,
                  'gallery'.translate(context),
                  () async {
                    Navigator.pop(context);
                    await ChatHelpers.pickGalleryAttachment((file) {
                      setState(() {
                        _attachment = file;
                      });
                      _showRecordButton.value = false;
                    });
                  },
                ),
                _buildAttachmentOption(
                  context,
                  Icons.insert_drive_file,
                  'Documents'.translate(context),
                  () async {
                    Navigator.pop(context);
                    await ChatHelpers.pickDocumentAttachment((file) {
                      setState(() {
                        _attachment = file;
                      });
                      _showRecordButton.value = false;
                    });
                  },
                ),
                _buildAttachmentOption(
                  context,
                  Icons.audiotrack,
                  'audio'.translate(context),
                  () async {
                    try {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.audio,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        final file = result.files.first;
                        _sendAudio(file.path);
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      Navigator.pop(context);
                      await HelperUtils.showSnackBarMessage(
                        context,
                        e.toString(),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: context.color.tertiaryColor.withValues(alpha: .2),
            child: Icon(
              icon,
              color: context.color.tertiaryColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          CustomText(
            label,
            fontSize: context.font.small,
            color: context.color.textColorDark,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attachmentExt =
        _attachment?.path?.split('.').last.toLowerCase() ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_attachment != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AttachmentPreview(
              attachment: _attachment!,
              isImage: ChatHelpers.supportedImageTypes.contains(attachmentExt),
              onRemove: _removeAttachment,
            ),
          ),
        Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: BottomAppBar(
            padding: const EdgeInsetsDirectional.all(10),
            color: context.color.secondaryColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    cursorColor: context.color.tertiaryColor,
                    minLines: 1,
                    maxLines: null,
                    style: TextStyle(
                      color: context.color.textColorDark,
                    ),
                    decoration: InputDecoration(
                      hintText: 'writeHere'.translate(context),
                      hintStyle: TextStyle(
                        color:
                            context.color.textColorDark.withValues(alpha: .6),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            BorderSide(color: context.color.tertiaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide:
                            BorderSide(color: context.color.tertiaryColor),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _attachment != null ? Icons.close : Icons.attachment,
                          color: context.color.textLightColor,
                        ),
                        onPressed: () {
                          if (_attachment != null) {
                            _removeAttachment();
                          } else {
                            _showAttachmentOptions(context);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder<bool>(
                  valueListenable: _showRecordButton,
                  builder: (_, showRecord, __) {
                    return showRecord
                        ? RecordButton(
                            controller: _recordAnimation,
                            callback: (val) => _sendAudio(val as String?),
                            isSending: false,
                          )
                        : GestureDetector(
                            onTap: _sendTextOrAttachment,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: context.color.tertiaryColor,
                              child: Icon(
                                Icons.send,
                                color: context.color.buttonColor,
                              ),
                            ),
                          );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AttachmentPreview extends StatelessWidget {
  const AttachmentPreview({
    required this.attachment,
    required this.isImage,
    required this.onRemove,
    super.key,
  });
  final PlatformFile attachment;
  final bool isImage;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return isImage
        ? GestureDetector(
            onTap: () {
              UiUtils.showFullScreenImage(
                context,
                provider: FileImage(File(attachment.path!)),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: context.color.borderColor, width: 1.5),
              ),
              child: Image.file(
                File(attachment.path!),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          )
        : ColoredBox(
            color: context.color.secondaryColor,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: AttachmentMessage(
                url: attachment.path!,
                isSentByMe: true,
              ),
            ),
          );
  }
}
