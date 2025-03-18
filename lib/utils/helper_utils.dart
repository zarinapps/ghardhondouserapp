import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

enum MessageType {
  success(successMessageColor),
  warning(warningMessageColor),
  error(errorMessageColor);

  const MessageType(this.value);
  final Color value;
}

class HelperUtils {
  static Future<bool> checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.ethernet);
  }

  static Future<File> compressImageFile(File file) async {
    try {
      final int fileSize = await file.length();
      if (fileSize <= 500000) {
        return file;
      }

      final String filePath = file.absolute.path;
      final int lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
      if (lastIndex == -1) {
        throw Exception("Unsupported file format for compression");
      }

      final Directory tempDir = await getTemporaryDirectory();
      final String outPath = "${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

      XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: 80,
      );

      if (compressedFile == null) {
        throw Exception("Compression failed, output file is null");
      }

      return File(compressedFile.path);
    } catch (e) {
      debugPrint("Image compression error: $e");
      return file;
    }
  }

  static Future<List<R>> parallelMap<R, T>(
    List<T> items,
    FutureOr<R> Function(T) mapper, {
    int concurrency = 1,
  }) async {
    final results = <R>[];
    final queue = StreamController<T>();
    final done = Completer<void>();

    for (var i = 0; i < concurrency; i++) {
      _startWorker<T, R>(queue.stream, results, mapper, done);
    }

    for (final element in items) {
      queue.add(element);
    }
    await queue.close();
    await done.future;
    return results;
  }

  static void _startWorker<T, R>(
    Stream<T> input,
    List<R> results,
    FutureOr<R> Function(T) mapper,
    Completer<void> done,
  ) {
    int processedItems = 0;

    input.listen(
      (element) async {
        final result = await mapper(element);
        results.add(result);
        processedItems++;

        if (processedItems >= results.length && !done.isCompleted) {
          done.complete();
        }
      },
    );
  }

  /// ✅ FIXED: Corrected `goToNextPage` method signature  
  static void goToNextPage(
    BuildContext context,
    String routeName, {
    Map? arguments,
    bool isReplace = false,
  }) {
    if (isReplace) {
      Navigator.of(context).pushReplacementNamed(routeName, arguments: arguments);
    } else {
      Navigator.of(context).pushNamed(routeName, arguments: arguments);
    }
  }

  /// ✅ FIXED: Corrected `share` method  
  static void share(BuildContext context, String text) {
    Share.share(text);
  }

  /// ✅ FIXED: Re-added `showSnackBarMessage` method  
  static Future<void> showSnackBarMessage(
    BuildContext context,
    String message, {
    int durationSeconds = 3,
    MessageType? type,
    bool isFloating = false,
    VoidCallback? onClose,
  }) async {
    final snackBar = SnackBar(
      content: Text(message),
      behavior: isFloating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      backgroundColor: type?.value,
      duration: Duration(seconds: durationSeconds),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    if (bytes == 0) return '0${suffixes[0]}';
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  static void killPreviousPages(BuildContext context, String routeName) {
    Navigator.of(context).pushNamedAndRemoveUntil(routeName, (route) => false);
  }
}

/// ✅ `StringCasingExtension` Fix (Corrected Version)
extension StringCasingExtension on String {
  String toCapitalized() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.toCapitalized())
        .join(' ');
  }
}
