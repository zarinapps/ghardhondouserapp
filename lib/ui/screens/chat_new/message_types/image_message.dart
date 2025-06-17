import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat_new/model.dart';
import 'package:flutter/material.dart';

class ImageMessage extends ChatMessage {
  @override
  String get chatMessageType => 'image';

  @override
  Widget render(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      margin: EdgeInsets.only(
        left: isSentByMe ? 50 : 0,
        right: isSentByMe ? 0 : 50,
      ),
      child: Column(
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSentByMe
                  ? context.color.tertiaryColor.withValues(alpha: .1)
                  : context.color.secondaryColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
                    onTap: () {
                      // Open image in full screen
                      Navigator.push(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (context) => Scaffold(
                            backgroundColor: Colors.black,
                            appBar: AppBar(
                              backgroundColor: Colors.black,
                              iconTheme:
                                  const IconThemeData(color: Colors.white),
                            ),
                            body: Center(
                              child: InteractiveViewer(
                                child: Image.network(
                                  file ?? '',
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 48,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      file ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (message != null && message.toString() != '[File]')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      message.toString(),
                      style: TextStyle(
                        color: context.color.textColorDark,
                      ),
                    ),
                  ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeAgo ?? '',
                      style: TextStyle(
                        fontSize: 10,
                        color: context.color.textLightColor,
                      ),
                    ),
                    if (isSentByMe) ...[
                      const SizedBox(width: 5),
                      Icon(
                        Icons.done_all,
                        size: 14,
                        color: isSent ?? false
                            ? Colors.blue
                            : context.color.textLightColor,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
