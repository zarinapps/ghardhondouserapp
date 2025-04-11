// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/payment/gatways/flutterwave.dart';
import 'package:ebroker/utils/payment/gatways/paypal.dart';
import 'package:ebroker/utils/payment/gatways/stripe_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentGatways {
  static openEnabled(
      BuildContext context, price, SubscriptionPackageModel package) {
    if (AppSettings.enabledPaymentGatway == 'paystack') {
    } else if (AppSettings.enabledPaymentGatway == 'paypal') {
      paypal(context, package);
    } else if (AppSettings.enabledPaymentGatway == 'razorpay') {
      razorpay(context, price: price, package: package);
    } else if (AppSettings.enabledPaymentGatway == 'stripe') {
      stripe(
        context,
        packageId: package,
        price: double.parse(price.toString()),
      );
    } else if (AppSettings.enabledPaymentGatway == 'flutterwave') {
      flutterwave(context, package);
    }
  }

  static String generateReference(String email) {
    late String platform;
    if (Platform.isIOS) {
      platform = 'I';
    } else if (Platform.isAndroid) {
      platform = 'A';
    }
    final reference =
        '${platform}_${email.split("@").first}_${DateTime.now().millisecondsSinceEpoch}';
    return reference;
  }

  static void stripe(
    BuildContext context, {
    required double price,
    required packageId,
  }) {
    openStripePaymentGateway(
      amount: price,
      awaitedOrderID: packageId.toString(),
      onError: (message) {},
      onSuccess: () {
        _purchase(context);
      },
      metadata: {'packageId': packageId.id, 'userId': HiveUtils.getUserId()},
    );
  }

  static void paypal(BuildContext context, SubscriptionPackageModel package) {
    Navigator.push<dynamic>(
      context,
      BlurredRouter(
        builder: (context) {
          return PaypalWidget(
            pacakge: package,
            onSuccess: (msg) {
              Navigator.pop(context, {'msg': msg, 'type': 'success'});
            },
            onFail: (msg) {
              Navigator.pop(context, {'msg': msg, 'type': 'fail'});
            },
          );
        },
      ),
    ).then((value) {
      //push and show dialog box about paypal success or failed, after that we call purchase method it will refresh API and check if package is purchased or not
      if (value != null) {
        Future.delayed(
          const Duration(milliseconds: 1000),
          () {
            UiUtils.showBlurredDialoge(
              context,
              dialoge: BlurredDialogBox(
                title: UiUtils.translate(
                  context,
                  value['type'] == 'success' ? 'success' : 'Failed',
                ),
                onAccept: () async {
                  if (value['type'] == 'success') {
                    await _purchase(context);
                  }
                },
                onCancel: () {
                  if (value['type'] == 'success') {
                    _purchase(context);
                  }
                },
                isAcceptContainesPush: true,
                content: CustomText(value['msg']?.toString() ?? ''),
              ),
            );
          },
        );
      }
    });
  }

  static void flutterwave(
      BuildContext context, SubscriptionPackageModel package) {
    Navigator.push<dynamic>(
      context,
      BlurredRouter(
        builder: (context) {
          return FlutterwaveWidget(
            pacakge: package,
            onSuccess: (msg) {
              Navigator.pop(context, {'msg': msg, 'type': 'success'});
            },
            onFail: (msg) {
              Navigator.pop(context, {'msg': msg, 'type': 'fail'});
            },
          );
        },
      ),
    ).then((value) {
      //push and show dialog box about paypal success or failed, after that we call purchase method it will refresh API and check if package is purchased or not
      if (value != null) {
        Future.delayed(
          const Duration(milliseconds: 1000),
          () {
            UiUtils.showBlurredDialoge(
              context,
              dialoge: BlurredDialogBox(
                title: UiUtils.translate(
                  context,
                  value['type'] == 'success' ? 'success' : 'Failed',
                ),
                onAccept: () async {
                  if (value['type'] == 'success') {
                    await _purchase(context);
                  }
                },
                onCancel: () {
                  if (value['type'] == 'success') {
                    _purchase(context);
                  }
                },
                isAcceptContainesPush: true,
                content: CustomText(value['msg']?.toString() ?? ''),
              ),
            );
          },
        );
      }
    });
  }

  static void razorpay(
    BuildContext context, {
    required price,
    required package,
  }) {
    final razorpay = Razorpay();

    final options = {
      'key': Constant.razorpayKey,
      'amount': price! * 100,
      'name': package.name,
      'description': '',
      'prefill': {
        'contact': HiveUtils.getUserDetails().mobile,
        'email': HiveUtils.getUserDetails().email,
      },
      'notes': {'package_id': package.id, 'user_id': HiveUtils.getUserId()},
    };

    if (Constant.razorpayKey != '') {
      razorpay
        ..open(options)
        ..on(
          Razorpay.EVENT_PAYMENT_SUCCESS,
          (
            PaymentSuccessResponse response,
          ) async {
            await _purchase(context);
          },
        )
        ..on(
          Razorpay.EVENT_PAYMENT_ERROR,
          (PaymentFailureResponse response) {
            HelperUtils.showSnackBarMessage(
              context,
              UiUtils.translate(context, 'purchaseFailed'),
            );
          },
        )
        ..on(
          Razorpay.EVENT_EXTERNAL_WALLET,
          (e) {},
        );
    } else {
      HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'setAPIkey'),
      );
    }
  }

  static Future<void> _purchase(BuildContext context) async {
    try {
      Future.delayed(
        Duration.zero,
        () {
          context.read<FetchSystemSettingsCubit>().fetchSettings(
                isAnonymous: false,
              );
          context.read<FetchSubscriptionPackagesCubit>().fetchPackages();

          HelperUtils.showSnackBarMessage(
            context,
            UiUtils.translate(context, 'success'),
            type: MessageType.success,
            messageDuration: 5,
          );

          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    } catch (e) {
      await HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'purchaseFailed'),
        type: MessageType.error,
      );
    }
  }
}
