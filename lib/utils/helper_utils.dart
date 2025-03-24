import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ebroker/data/helper/custom_exception.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:http/http.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

enum MessageType {
  success(successMessageColor),
  warning(warningMessageColor),
  error(errorMessageColor);

  const MessageType(this.value);

  final Color value;
}

class HelperUtils {
  static Future<bool> checkInternet() async {
    var check = false;
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      check = true;
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      check = true;
    } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
      check = true;
    }
    return check;
  }

  static Future<bool> hasStoragePermissionGiven() async {
    if (Platform.isIOS) {
      var permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        return permissionGiven = (await Permission.storage.request()).isGranted;
      }
      return permissionGiven;
    }
    //if it is for android
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    if (androidDeviceInfo.version.sdkInt < 33) {
      var permissionGiven = await Permission.storage.isGranted;
      if (!permissionGiven) {
        return permissionGiven = (await Permission.storage.request()).isGranted;
      }
      return permissionGiven;
    } else {
      var permissionGiven = await Permission.photos.isGranted;
      if (!permissionGiven) {
        return permissionGiven = (await Permission.photos.request()).isGranted;
      }
      return permissionGiven;
    }
  }

  static String checkHost(String url) {
    if (url.endsWith('/')) {
      return url;
    } else {
      return '$url/';
    }
  }

  static Map<dynamic, Type> runtimeValueLog(Map map) {
    return map.map((key, value) => MapEntry(key, value.runtimeType));
  }

  static Future<String?> getDownloadPath({
    Function(dynamic err)? onError,
  }) async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        // if (!await directory.exists()) {
        //   directory = await getDownloadsDirectory();
        // }
      }
    } catch (err) {
      onError?.call(err);
    }
    return directory?.path;
  }

  static Future<void> precacheSVG(List<String> urls) async {
    bool isSvgUrl(String url) {
      // Convert the URL to lowercase for a case-insensitive check
      final lowercaseUrl = url.toLowerCase();

      // Check if the URL ends with ".svg"
      return lowercaseUrl.endsWith('.svg');
    }

    for (final imageUrl in urls) {
      if (isSvgUrl(imageUrl)) {
        // SvgNetworkLoader loader = SvgNetworkLoader(imageUrl);
        // ByteData byteData = await svg.cache
        //     .putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
        // await precachePicture(
        //   NetworkPicture(
        //     SvgPicture.svgByteDecoderBuilder,
        //     imageUrl,
        //   ),
        //   null,
        // );
      } else {
        continue;
      }
    }
  }

  static Future<void> printServerError(
    String url, {
    required int statusCode,
    required Map parameter,
    required String response,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/log($statusCode).html')
      ..writeAsStringSync('''
          $url,<br><br>
          $parameter,<br></br>
          Response: <br></br>
          $response
          ''');

    if (statusCode == 500) {
      await OpenFilex.open(file.path);
    }
  }

  static int comparableVersion(String version) {
    //removing dot from version and parsing it into int
    final plain = version.replaceAll('.', '');

    return int.parse(plain);
  }

  static String nativeDeepLinkUrlOfProperty(String slug) {
    return 'https://${AppSettings.shareNavigationWebUrl}/properties-details/$slug/';
  }

  static void share(BuildContext context, int propertyId, String slugId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.backgroundColor,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: CustomText('copylink'.translate(context)),
              onTap: () async {
                var deepLink = '';
                if (AppSettings.deepLinkingType == DeepLinkType.native) {
                  deepLink = nativeDeepLinkUrlOfProperty(slugId);
                } else {
                  deepLink = DeepLinkManager.buildAppLink(propertyId);
                }

                await Clipboard.setData(ClipboardData(text: deepLink));

                Future.delayed(Duration.zero, () {
                  Navigator.pop(context);
                  HelperUtils.showSnackBarMessage(
                    context,
                    'copied'.translate(context),
                  );
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: CustomText('share'.translate(context)),
              onTap: () async {
                var deepLink = '';

                if (AppSettings.deepLinkingType == DeepLinkType.native) {
                  deepLink = nativeDeepLinkUrlOfProperty(slugId);
                } else {
                  deepLink = DeepLinkManager.buildAppLink(propertyId);
                }

                final text =
                    '${'sharePropertyDescription'.translate(context)}\n$deepLink';
                await Share.share(text);
              },
            ),
          ],
        );
      },
    );
  }

  static lockOrientation() {}

  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static bool checkIsUserInfoFilled({String name = '', String email = ''}) {
    final chkname = name;
    if (name.trim().isEmpty) {
      // chkname = Constant.session.getStringData(Session.keyUserName);
    }
    return chkname.trim().isNotEmpty;
  }

  static String mobileNumberWithoutCountryCode() {
    final mobile = HiveUtils.getUserDetails().mobile;

    final String? countryCode = HiveUtils.getCountryCode();

    final countryCodeLength = countryCode?.length ?? 0;

    final mobileNumber = mobile!.substring(countryCodeLength, mobile.length);

    return mobileNumber;
  }

  static Future<void> showSnackBarMessage(
    BuildContext? context,
    String message, {
    int messageDuration = 3,
    MessageType? type,
    bool? isFloating,
    VoidCallback? onClose,
  }) async {
    final snackBar = ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        content: CustomText(message),
        behavior: (isFloating ?? false) ? SnackBarBehavior.floating : null,
        backgroundColor: type?.value ?? successMessageColor,
        duration: Duration(seconds: messageDuration),
      ),
    );
    final snackBarClosedReason = await snackBar.closed;
    if (SnackBarClosedReason.values.contains(snackBarClosedReason)) {
      onClose?.call();
    }
  }

  static Future sendApiRequest(
    String url,
    Map<String, dynamic> body,
    isPost,
    BuildContext context, {
    bool passUserid = true,
  }) async {
    final headersData = <String, String>{
      'accept': 'application/json',
    };

    final token = HiveUtils.getJWT().toString();
    if (token.trim().isNotEmpty) {
      headersData['Authorization'] = 'Bearer $token';
    }
    if (passUserid && HiveUtils.isUserAuthenticated()) {
      // body[Api.userid] = HiveUtils.getUserId().toString();
    }
    Response response;
    try {
      if (isPost) {
        response = await post(
          Uri.parse(Constant.baseUrl + url),
          body: body.isNotEmpty ? body : null,
          headers: headersData,
        );
      } else {
        response = await get(
          Uri.parse(Constant.baseUrl + url),
          headers: headersData,
        );
      }
      await Future.delayed(
        Duration.zero,
        () {
          return getJsonResponse(
            context,
            response: response,
          );
        },
      );
    } on SocketException {
      throw FetchDataException('noInternetErrorMsg'.translate(context));
    } on TimeoutException {
      throw FetchDataException('nodatafound'.translate(context));
    } on Exception catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<String> getJsonResponse(
    BuildContext context, {
    bool isfromfile = false,
    StreamedResponse? streamedResponse,
    Response? response,
  }) async {
    int code;
    if (isfromfile) {
      code = streamedResponse!.statusCode;
    } else {
      code = response!.statusCode;
    }
    switch (code) {
      case 200:
        if (isfromfile) {
          final responseData = await streamedResponse!.stream.toBytes();
          return String.fromCharCodes(responseData);
        } else {
          return response!.body;
        }

      case 400:
        throw BadRequestException(response!.body);
      case 401:
        /* Constant.isUserDeactivated = true;
        print("isDeactivated ? -- ${Constant.isUserDeactivated}");
        break; */

        Map getdata;
        getdata = {};
        if (isfromfile) {
          final responseData = await streamedResponse!.stream.toBytes();
          getdata = json.decode(String.fromCharCodes(responseData));
        } else {
          getdata = json.decode(response!.body);
        }

        Future.delayed(
          Duration.zero,
          () {
            showSnackBarMessage(context, getdata[Api.message]);
          },
        );
        throw UnauthorisedException(getdata[Api.message]);
      case 403:
        throw UnauthorisedException(response!.body);
      case 500:
      default:
        throw FetchDataException(
          'Error occurred while Communication with Server with StatusCode: $code',
        );
    }
  }

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ['b', 'kb', 'mb', 'gb', 'tb'];
    if (bytes == 0) return '0${suffixes[0]}';
    final i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

  static void killPreviousPages(BuildContext context, var nextPage, var args) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(nextPage, (route) => false, arguments: args);
  }

  static void goToNextPage(
    var nextPage,
    BuildContext bContext,
    isReplace, {
    Map? args,
  }) {
    if (isReplace) {
      Navigator.of(bContext).pushReplacementNamed(nextPage, arguments: args);
    } else {
      Navigator.of(bContext).pushNamed(nextPage, arguments: args);
    }
  }

  static String setFirstLetterUppercase(String value) {
    if (value.isNotEmpty) value.replaceAll('_', ' ');
    return value.toTitleCase();
  }

  static Widget checkVideoType(
    String url, {
    required Widget Function() onYoutubeVideo,
    required Widget Function() onOtherVideo,
  }) {
    final youtubeDomains = ['youtu.be', 'youtube.com'];

    final uri = Uri.parse(url);
    final host = uri.host.replaceAll('www.', '');
    if (youtubeDomains.contains(host)) {
      return onYoutubeVideo.call();
    } else {
      return onOtherVideo.call();
    }
  }

  static CountryService countryCodeService = CountryService();

  /// it will return user's sim cards country code
  static Future<Country> getSimCountry() async {
    final countryList = countryCodeService.getAll();
    String? simCountryCode;

    try {
      simCountryCode = await FlutterSimCountryCode.simCountryCode;
    } catch (e) {
      if (kDebugMode) {
        print('getSimCountryCode error $e');
      }
    }

    var simCountry = countryList.firstWhere(
      (element) {
        return element.phoneCode == simCountryCode;
      },
      orElse: () {
        return countryList
            .where(
              (element) => element.phoneCode == Constant.defaultCountryCode,
            )
            .first;
      },
    );

    if (Constant.isDemoModeOn) {
      simCountry = countryList
          .where((element) => element.phoneCode == Constant.demoCountryCode)
          .first;
    }

    return simCountry;
  }

  static bool isYoutubeVideo(String url) {
    final youtubeDomains = ['youtu.be', 'youtube.com'];

    final uri = Uri.parse(url);
    final host = uri.host.replaceAll('www.', '');
    if (youtubeDomains.contains(host)) {
      return true;
    } else {
      return false;
    }
  }

  static Future<File?> compressImageFile(File file) async {
    try {
      final compressedFile = await FlutterNativeImage.compressImage(
        file.path,
        quality: Constant.uploadImageQuality,
      );
      return File(compressedFile.path);
    } catch (e) {
      return null; //If any error occurs during compression, the process is stopped.
    }
  }
}

///Post Frame Callback
void postFrame(void Function(Duration t) fn) {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    fn.call(timeStamp);
  });
}

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

extension ListExtensions<T> on List<T> {
  Future<List<R>> parallelMap<R>(
    FutureOr<R> Function(T) mapper, {
    int concurrency = 1,
  }) async {
    final results = <R>[];
    final queue = StreamController<T>.broadcast();
    final done = Completer();

    // Start worker functions
    for (var i = 0; i < concurrency; i++) {
      _startWorker(queue.stream, results, mapper, done);
    }

    // Add elements to the queue
    for (final element in this) {
      queue.add(element);
    }
    await queue.close();

    // Wait for all workers to finish
    await done.future;

    return results;
  }

  void _startWorker<T, R>(
    Stream<T> input,
    List<R> results,
    FutureOr<R> Function(T) mapper,
    Completer done,
  ) {
    input.listen(
      (element) async {
        final result = await mapper(element);
        results.add(result);
      },
      onDone: () {
        if (!done.isCompleted && results.length == length) {
          done.complete();
        }
      },
    );
  }
}
