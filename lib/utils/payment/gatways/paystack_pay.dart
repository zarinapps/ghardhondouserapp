import 'dart:developer';

import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/payment/gatways/paystack.dart';
import 'package:ebroker/utils/payment/lib/payment.dart';
import 'package:ebroker/utils/payment/lib/purchase_package.dart';
import 'package:flutter/material.dart';

class Paystack extends Payment {
  SubscriptionPackageModel? _modal;
  @override
  void pay(BuildContext context) {
    if (_modal == null) {
      log('Please set modal');
    }
    isPaymentGatewayOpen = true;
    Navigator.push<dynamic>(
      context,
      BlurredRouter(
        builder: (context) {
          return PaystackWidget(
            pacakge: _modal!,
            onSuccess: (msg) {
              Navigator.pop(context, {
                'msg': msg,
                'type': 'success',
              });
            },
            onFail: (msg) {
              Navigator.pop(context, {'msg': msg, 'type': 'fail'});
            },
          );
        },
      ),
    ).then((dynamic value) {
      isPaymentGatewayOpen = false;
      if (value != null && value is bool) {
        HelperUtils.showSnackBarMessage(
          context,
          value == true ? '' : 'Payment Failed',
        );
        return;
      }
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
                    emit(Success(message: 'Success'));
                    // _purchase(context);
                  }
                  if (value['type'] == 'Failed') {
                    emit(
                      Failure(
                        message: 'Something went wrong while making payment',
                      ),
                    );
                  }
                },
                onCancel: () {
                  if (value['type'] == 'success') {
                    emit(Success(message: 'Success'));
                  }
                  if (value['type'] == 'Failed') {
                    emit(
                      Failure(
                        message: 'Something went wrong while making payment',
                      ),
                    );
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

  @override
  Paystack setPackage(SubscriptionPackageModel modal) {
    _modal = modal;
    return this;
  }

  @override
  Future<void> onEvent(
    BuildContext context,
    covariant PaymentStatus currentStatus,
  ) async {
    if (currentStatus is Success) {
      await PurchasePackage().purchase(context);
    }
  }
}

// import 'dart:developer';
// import 'dart:io';
//
// import 'package:ebroker/data/model/subscription_pacakage_model.dart';
// import 'package:ebroker/utils/helper_utils.dart';
// import 'package:ebroker/utils/payment/lib/payment.dart';
// import 'package:ebroker/utils/payment/lib/purchase_package.dart';
// import 'package:ebroker/utils/ui_utils.dart';
// import 'package:flutter/material.dart';
//
// class Paystack extends Payment {
//   SubscriptionPackageModel? _model;
//
//
//   void init(String publicKey) {}
//
//   @override
//   Future<void> onEvent(
//     BuildContext context,
//     covariant PaymentStatus currentStatus,
//   ) async {
//     if (currentStatus is Success) {
//       await PurchasePackage().purchase(context);
//     }
//   }
//
//   @override
//   Future<void> pay(BuildContext context) async {
//     if (_model == null) {
//       log('Please setPackage');
//     }
//     isPaymentGatewayOpen = true;
//
//
//     final checkoutResponse = ;
//     isPaymentGatewayOpen = false;
//
//   }
//
//   String generateReference(String email) {
//     late String platform;
//     if (Platform.isIOS) {
//       platform = 'I';
//     } else if (Platform.isAndroid) {
//       platform = 'A';
//     }
//     final reference =
//         '${platform}_${email.split("@").first}_${DateTime.now().millisecondsSinceEpoch}';
//     return reference;
//   }
//
//   @override
//   Payment setPackage(SubscriptionPackageModel modal) {
//     _model = modal;
//     return this;
//   }
// }
