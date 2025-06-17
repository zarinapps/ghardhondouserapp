import 'package:dio/dio.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class DownloadableDocuments extends StatefulWidget {
  const DownloadableDocuments({required this.url, super.key});
  final String url;

  @override
  State<DownloadableDocuments> createState() => _DownloadableDocumentsState();
}

class _DownloadableDocumentsState extends State<DownloadableDocuments> {
  bool downloaded = false;
  Dio dio = Dio();
  ValueNotifier<double> percentage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  Future<String?>? path() async {
    final downloadPath = await HelperUtils.getDownloadPath();
    return downloadPath;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.url.split('/').last;
    return ListTile(
      dense: true,
      title: CustomText(
        name,
        fontSize: context.font.large,
        color: context.color.textColorDark.withValues(alpha: 0.9),
      ),
      trailing: ValueListenableBuilder(
        valueListenable: percentage,
        builder: (context, value, child) {
          if (value != 0.0 && value != 1.0) {
            return SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                value: value,
                color: context.color.tertiaryColor,
              ),
            );
          }
          if (downloaded) {
            return IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              splashRadius: 1,
              icon: const Icon(Icons.file_open),
              onPressed: () async {
                final downloadPath = await path();

                await OpenFilex.open('$downloadPath/$name');
              },
            );
          }
          return IconButton(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerRight,
            splashRadius: 1,
            icon: const Icon(Icons.download),
            onPressed: () async {
              final downloadPath = await path();
              final storagePermission =
                  await HelperUtils.hasStoragePermissionGiven();
              if (storagePermission) {
                await dio.download(
                  widget.url,
                  '$downloadPath/$name',
                  onReceiveProgress: (count, total) async {
                    percentage.value = count / total;
                    if (percentage.value == 1.0) {
                      downloaded = true;
                      setState(() {});
                      await OpenFilex.open('$downloadPath/$name');
                    }
                  },
                );
              } else {
                await HelperUtils.showSnackBarMessage(
                  context,
                  'Storage Permission denied!',
                );
              }
            },
          );
        },
      ),
    );
  }
}
