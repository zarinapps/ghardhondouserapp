import 'dart:async';
import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/settings.dart';
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
          _handleDeepLinks(context, Uri.parse(initialLink));
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
      (dynamic event) {
        final link = event.toString();
        if (link.isNotEmpty) {
          _handleDeepLinks(context, Uri.parse(link));
        }
      },
      onError: (Object error) {
        if (kDebugMode) {
          print('Error receiving deep link: $error');
        }
      },
    );
  }

  static Future<void> _handleDeepLinks(BuildContext context, Uri? uri) async {
    if (uri == null) {
      return;
    }

    if (uri.path.contains('/properties-details/')) {
      // Extract slug from path
      final slug = uri.pathSegments.last;

      if (slug.isNotEmpty) {
        try {
          final dataOutput = await PropertyRepository().fetchBySlug(slug);

          // Unified navigation approach with proper flag management
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Constant.navigatorKey.currentState != null) {
              Constant.navigateTo(
                Routes.propertyDetails,
                arguments: {
                  'propertyData': dataOutput,
                },
              );
            } else {
              print('deeplinkManager navigator is null');
            }
          });
        } catch (e, st) {
          print('deeplinkManager Error handling deeplink: $e $st');
        }
      }
    }
  }

  static void dispose() {
    _deepLinkSubscription?.cancel();
  }

  static String buildAppLink(int propertyId) {
    final uri = Uri(
      scheme: 'http',
      host: AppSettings.deepLinkName,
      path: '/properties-details/$propertyId',
    );

    return uri.toString();
  }
}
