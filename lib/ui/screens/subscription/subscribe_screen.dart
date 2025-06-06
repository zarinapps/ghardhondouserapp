// ignore_for_file: must_be_immutable, depend_on_referenced_packages

import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/payment/gatways/paypal.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

/////THIS SCREEN IS NOT IN USE NOW

class SubscriptionScreen extends StatefulWidget {
  SubscriptionScreen({
    required this.pacakge,
    required this.isPackageAlready,
    super.key,
  });
  SubscriptionPackageModel pacakge;
  final bool isPackageAlready;
  static Route route(RouteSettings settings) {
    final arguments = settings.arguments! as Map;
    return BlurredRouter(
      builder: (context) {
        return SubscriptionScreen(
          pacakge: arguments['package'] as SubscriptionPackageModel? ??
              SubscriptionPackageModel(
                id: 0,
                name: '',
                packageType: '',
                price: 0,
                duration: 0,
                createdAt: DateTime.now(),
                features: [],
                iosProductId: '',
              ),
          isPackageAlready: arguments['isPackageAlready'] as bool? ?? false,
        );
      },
    );
  }

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final Razorpay _razorpay = Razorpay();
  int selectedPaymentMethod = 1;
  late WebViewController controllerGlobal;
  late Map<int, VoidCallback> paymentMethodIndex = {
    1: _paystack,
    2: _openPaypal,
    3: _openRazorPay,
  };

  _openPaypal() {
    Navigator.push<dynamic>(
      context,
      BlurredRouter(
        builder: (context) {
          return PaypalWidget(
            pacakge: widget.pacakge,
            onSuccess: (msg) {
              Navigator.pop(
                context,
                {
                  'msg': msg,
                  'type': 'success',
                },
              );
            },
            onFail: (msg) {
              Navigator.pop(
                context,
                {
                  'msg': msg,
                  'type': 'fail',
                },
              );
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
                    _purchase();
                  }
                },
                onCancel: () {
                  if (value['type'] == 'success') {
                    _purchase();
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

  _purchase() async {
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
        'purchaseFailed',
        type: MessageType.error,
      );
    }
  }

  getPaypalURL() async {
    await Api.get(
      url: Api.paypal,
      queryParameters: {
        Api.packageId: widget.pacakge.id,
        'amount': widget.pacakge.price.toString(),
      },
    );
  }

  _openRazorPay() async {
    final options = {
      'key': Constant.razorpayKey,
      'amount': widget.pacakge.price * 100,
      'name': widget.pacakge.name,
      'description': '',
      'prefill': {
        'contact': HiveUtils.getUserDetails().mobile,
        'email': HiveUtils.getUserDetails().email,
      },
      'notes': {
        'package_id': widget.pacakge.id,
        'user_id': HiveUtils.getUserId(),
      },
    };

    if (Constant.razorpayKey != '') {
      _razorpay
        ..open(options)
        ..on(
          Razorpay.EVENT_PAYMENT_SUCCESS,
          _razorpayHandlePaymentSuccess,
        )
        ..on(
          Razorpay.EVENT_PAYMENT_ERROR,
          _razorpayHandlePaymentError,
        )
        ..on(
          Razorpay.EVENT_EXTERNAL_WALLET,
          _razorpayHandleExternalWallet,
        );
    } else {
      await HelperUtils.showSnackBarMessage(
        context,
        UiUtils.translate(context, 'setAPIkey'),
      );
    }
  }

  _paystack() async {}

  String generateReference(String email) {
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

  _onTapSubscribe() async {
    paymentMethodIndex[selectedPaymentMethod]?.call();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _razorpayHandlePaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    await _purchase();
  }

  void _razorpayHandlePaymentError(PaymentFailureResponse response) {
    HelperUtils.showSnackBarMessage(context, 'purchaseFailed');
  }

//not in use
  void _razorpayHandleExternalWallet(ExternalWalletResponse response) {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'selectPaymentMethod'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            children: <Widget>[
              RadioListTile(
                title: CustomText(
                  UiUtils.translate(
                    context,
                    'paystack',
                  ),
                ),
                activeColor: context.color.tertiaryColor,
                secondary: paymentIcon(context, AppIcons.paystack),
                controlAffinity: ListTileControlAffinity.trailing,
                value: 1,
                groupValue: selectedPaymentMethod,
                onChanged: (v) {
                  selectedPaymentMethod = v as int;
                  setState(
                    () {},
                  );
                },
              ),
              const SizedBox(
                height: 5,
              ),
              RadioListTile(
                title: CustomText(
                  UiUtils.translate(context, 'paypal'),
                ),
                activeColor: context.color.tertiaryColor,
                secondary: paymentIcon(
                  context,
                  AppIcons.paypal,
                ),
                controlAffinity: ListTileControlAffinity.trailing,
                value: 2,
                groupValue: selectedPaymentMethod,
                onChanged: (v) {
                  selectedPaymentMethod = v!;
                  setState(() {});
                },
              ),
              const SizedBox(
                height: 5,
              ),
              RadioListTile(
                title: CustomText(
                  UiUtils.translate(context, 'razorpay'),
                ),
                activeColor: context.color.tertiaryColor,
                secondary: paymentIcon(context, AppIcons.razorpay),
                controlAffinity: ListTileControlAffinity.trailing,
                value: 3,
                groupValue: selectedPaymentMethod,
                onChanged: (v) {
                  selectedPaymentMethod = v!;
                  setState(() {});
                },
              ),
            ],
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: UiUtils.buildButton(
              context,
              onPressed: _onTapSubscribe,
              radius: 12,
              height: 48.rh(context),
              buttonTitle: UiUtils.translate(context, 'subscribe'),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentIcon(BuildContext context, String icon) {
    return Container(
      width: 60.rw(context),
      height: 41.rh(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color(0xff072654),
      ),
      child: UiUtils.getSvg(icon, fit: BoxFit.none),
    );
  }
}
