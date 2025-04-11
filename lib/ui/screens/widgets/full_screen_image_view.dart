import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ebroker/app/app.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class FullScreenImageView extends StatefulWidget {
  const FullScreenImageView({
    required this.provider,
    super.key,
    this.showDownloadButton,
    this.onTapDownload,
  });
  final ImageProvider provider;
  final bool? showDownloadButton;
  final VoidCallback? onTapDownload;

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  String getExtentionOfFile() {
    if (widget.provider is NetworkImage) {
      return (widget.provider as NetworkImage).getURL().split('.').last;
    }
    return '';
  }

  String getFileName() {
    if (widget.provider is NetworkImage) {
      return (widget.provider as NetworkImage).getURL().split('.').last;
    }
    return (widget.provider as NetworkImage).getURL().split('/').last;
  }

  Future<void> downloadFile() async {
    try {
      final downloadPath = await getDownloadPath();
      if (widget.provider is! NetworkImage) {
        return;
      }

      await Dio().download(
        (widget.provider as NetworkImage).getURL(),
        '${downloadPath!}/${getFileName()}',
        onReceiveProgress: (int count, int total) async {
          final persontage = count / total;

          if (persontage == 1) {
            await HelperUtils.showSnackBarMessage(
              context,
              UiUtils.translate(context, 'fileSavedIn'),
              type: MessageType.success,
            );

            await OpenFilex.open('$downloadPath/${getFileName()}');
          }
          setState(() {});
        },
      );
    } catch (e) {
      log('Download Error is: $e');
      await HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'errorFileSave'),
        type: MessageType.success,
      );
    }
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      }
    } catch (err) {
      if (kDebugMode) {
        await HelperUtils.showSnackBarMessage(
          context,
          UiUtils.translate(context, 'fileNotSaved'),
          type: MessageType.success,
        );
      }
    }
    return directory?.path;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        Navigator.pop(context);
      },
      child: SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            actions: [
              if (widget.showDownloadButton == true &&
                  widget.provider is NetworkImage)
                IconButton(
                  onPressed: () {
                    downloadFile();
                    widget.onTapDownload?.call();
                  },
                  icon: const Icon(Icons.download),
                ),
              const SizedBox(
                width: 10,
              ),
            ],
            backgroundColor: Colors.transparent,
            leading: Container(
              margin: EdgeInsetsDirectional.only(start: 8),
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: UiUtils.getSvg(
                  AppIcons.arrowLeft,
                  matchTextDirection: true,
                  fit: BoxFit.none,
                  color: context.color.tertiaryColor,
                ),
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(17, 0, 0, 0),
          body: InteractiveViewer(
            maxScale: 4,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: GestureDetector(
                  onTap: () {},
                  child: Image(
                    image: widget.provider,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: context.color.tertiaryColor
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: UiUtils.getImage(
                          appSettings.placeholderLogo!,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return FittedBox(
                        fit: BoxFit.none,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: UiUtils.progress(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension S on NetworkImage {
  String getURL() {
    return url;
  }
}
