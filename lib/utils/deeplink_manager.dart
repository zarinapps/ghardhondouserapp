import 'dart:async';
import 'dart:developer';
import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/helper/widgets.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeepLinkManager {
  static const MethodChannel _channel =
      MethodChannel('app.channel.shared.data');
  static bool _isInitialLinkHandled = false;
  static StreamSubscription<dynamic>? _deepLinkSubscription;

  static Future<void> initDeepLinks(BuildContext context) async {
    // Handle initial link
    try {
      final initialLink = await _getInitialLink();

      // Handle initial deep link after the app is fully initialized
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (initialLink != null && !_isInitialLinkHandled) {
          _isInitialLinkHandled = true;
          handleDeepLinks(
            context,
            Uri.parse(initialLink),
            initialLink.split('/').last,
          );
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial deep link: $e');
      }
    }

    // Listen for subsequent deep links
    _setupDeepLinkListener(context);
  }

  static Future<String?> _getInitialLink() async {
    try {
      final initialLink = await _channel.invokeMethod<String>('getInitialLink');
      return initialLink;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Failed to get initial link: ${e.message}');
      }
      return null;
    }
  }

  static void _setupDeepLinkListener(BuildContext context) {
    // Cancel any existing subscription
    _deepLinkSubscription?.cancel();

    // Listen to new links
    _deepLinkSubscription = const EventChannel('app.channel.shared.data/link')
        .receiveBroadcastStream()
        .listen(
      (event) {
        final link = event.toString();
        if (link.isNotEmpty) {
          handleDeepLinks(context, Uri.parse(link), link.split('/').last);
        }
      },
      onError: (Object error) {
        if (kDebugMode) {
          print('Error receiving deep link: $error');
        }
      },
    );
  }

  static Future<void> handleDeepLinks(
    BuildContext context,
    Uri? uri,
    String? slug,
  ) async {
    if (uri == null || slug == null) {
      return;
    }

    if (uri.path.contains('/properties-details/')) {
      if (slug.isNotEmpty) {
        try {
          unawaited(Widgets.showLoader(context));
          final dataOutput = await PropertyRepository().fetchBySlug(slug);

          // Use WidgetsBinding to ensure we navigate after the frame is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Widgets.hideLoader(context);
            // Check if navigator key is available and navigate directly
            if (Constant.navigatorKey.currentState != null) {
              Navigator.of(Constant.navigatorKey.currentContext!).pushNamed(
                Routes.propertyDetails,
                arguments: {
                  'propertyData': dataOutput,
                },
              );
            }
          });
        } catch (e, st) {
          Widgets.hideLoader(context);
          log('deeplinkManager Error handling deeplink: $e $st');
        } finally {
          Widgets.hideLoader(context);
        }
      }
    }
  }

  static void dispose() {
    _deepLinkSubscription?.cancel();
  }
}
