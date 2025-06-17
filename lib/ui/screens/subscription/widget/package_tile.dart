import 'package:dio/dio.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/data/repositories/subscription_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/payment/in_app_purchase/in_app_purchase_manager.dart';
import 'package:flutter/material.dart';

class SubscriptionPackageTile extends StatefulWidget {
  const SubscriptionPackageTile({
    required this.onTap,
    required this.package,
    required this.packageFeatures,
    super.key,
  });

  final SubscriptionPackageModel package;
  final List<AllFeature> packageFeatures;
  final VoidCallback onTap;

  @override
  State<SubscriptionPackageTile> createState() =>
      _SubscriptionPackageTileState();
}

class _SubscriptionPackageTileState extends State<SubscriptionPackageTile> {
  InAppPurchaseManager inAppPurchase = InAppPurchaseManager();
  MultipartFile? _bankReceiptFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(top: 10, start: 16, end: 16),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.color.borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          buildPackageTitle(),
          packageFeaturesAndValidity(),
          buildSeparator(),
          buildPriceAndSubscribe(),
        ],
      ),
    );
  }

  String getDuration({required int duration, required BuildContext context}) {
    final days = duration ~/ 24;
    return '$days';
  }

  Widget buildPriceAndSubscribe() {
    final packageDuration = getDuration(
      duration: widget.package.duration,
      context: context,
    );
    final isUnderReview = widget.package.packageStatus == 'review';
    final isRejected = widget.package.packageStatus == 'rejected';
    return Column(
      children: [
        if (isUnderReview) ...[
          const SizedBox(
            height: 8,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.orangeAccent,
              ),
              const SizedBox(
                width: 5,
              ),
              CustomText(
                'adminVerificationPending'.translate(context),
                fontSize: context.font.normal,
                color: Colors.orangeAccent,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
        ],
        Container(
          margin: EdgeInsets.only(
            top: isUnderReview ? 8 : 18,
            bottom: 18,
            left: 16,
            right: 16,
          ),
          padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 18),
          decoration: BoxDecoration(
            color: context.color.tertiaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    widget.package.price == 0
                        ? 'free'.translate(context)
                        : '${Constant.currencySymbol} ${widget.package.price}',
                    fontSize: context.font.larger,
                    color: context.color.tertiaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomText(
                    '$packageDuration ${packageDuration == '1' ? 'day'.translate(context) : 'days'.translate(context)}',
                    fontSize: context.font.large,
                    color: context.color.tertiaryColor,
                  ),
                ],
              ),
              const Spacer(),
              if (isUnderReview)
                UiUtils.buildButton(
                  context,
                  height: 45.rh(context),
                  autoWidth: true,
                  radius: 6,
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.transactionHistory);
                  },
                  buttonTitle: 'view'.translate(context),
                )
              else if (isRejected)
                buildUploadReceiptButton(
                  transactionId: widget.package.paymentTransactionId ?? '',
                )
              else
                UiUtils.buildButton(
                  context,
                  height: 45.rh(context),
                  autoWidth: true,
                  radius: 6,
                  onPressed: widget.onTap,
                  buttonTitle: 'subscribe'.translate(context),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSeparator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: MySeparator(
        color: context.color.tertiaryColor.withValues(alpha: 0.7),
      ),
    );
  }

  Widget buildPackageTitle() {
    return Container(
      height: 50,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: context.color.textColorDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: CustomText(
        widget.package.name,
        fontSize: context.font.larger,
        color: context.color.secondaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget packageFeaturesAndValidity() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          buildValidity(
            duration: widget.package.duration.toString(),
          ),
          buildPackageFeatures(
            packageFeatures: widget.packageFeatures,
            package: widget.package,
          ),
        ],
      ),
    );
  }

  Widget buildValidity({required String duration}) {
    final packageDuration =
        getDuration(duration: int.parse(duration), context: context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          UiUtils.getSvg(
            AppIcons.featureAvailable,
            height: 20,
            width: 20,
          ),
          const SizedBox(
            width: 5,
          ),
          CustomText(
            '${'validUntil'.translate(context)} $packageDuration ${packageDuration == '1' ? 'day'.translate(context) : 'days'.translate(context)}',
            fontSize: context.font.small,
            color: context.color.textColorDark,
          ),
        ],
      ),
    );
  }

  Widget buildPackageFeatures({
    required List<AllFeature> packageFeatures,
    required SubscriptionPackageModel package,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packageFeatures.length,
      itemBuilder: (context, index) {
        final allFeatures = packageFeatures[index];
        final includedFeatures = package.features
            .where((element) => element.id == allFeatures.id)
            .toList();
        // Check if we have matching features before accessing
        var getLimit = '';
        if (includedFeatures.isNotEmpty) {
          if (includedFeatures[0].limit?.toString() != '0') {
            getLimit = includedFeatures[0].limit?.toString() ??
                includedFeatures[0].limitType.toString();
          } else {
            getLimit = includedFeatures[0].limitType.name;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              UiUtils.getSvg(
                package.features.any((element) => element.id == allFeatures.id)
                    ? AppIcons.featureAvailable
                    : AppIcons.featureNotAvailable,
                height: 20,
                width: 20,
              ),
              const SizedBox(
                width: 5,
              ),
              CustomText(
                allFeatures.name,
                fontSize: context.font.small,
                color: context.color.textColorDark,
              ),
              const SizedBox(
                width: 5,
              ),
              if (getLimit != '')
                CustomText(
                  ': ${getLimit.firstUpperCase()}',
                  fontSize: context.font.small,
                  color: context.color.textColorDark,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget buildUploadReceiptButton({
    required String transactionId,
  }) {
    return UiUtils.buildButton(
      context,
      height: 45.rh(context),
      autoWidth: true,
      radius: 6,
      onPressed: () async {
        final filePickerResult = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [
            'jpeg',
            'png',
            'jpg',
            'pdf',
            'doc',
            'docx',
          ],
        );
        if (filePickerResult != null) {
          _bankReceiptFile = await MultipartFile.fromFile(
            filePickerResult.files.first.path!,
            filename: filePickerResult.files.first.path!.split('/').last,
          );
        }
        if (_bankReceiptFile == null) {
          await HelperUtils.showSnackBarMessage(
            context,
            'pleaseUploadReceipt'.translate(context),
          );
          return;
        }
        try {
          final result = await SubscriptionRepository().uploadBankReceiptFile(
            paymentTransactionId: transactionId,
            file: _bankReceiptFile!,
          );
          if (result['error'] == false) {
            unawaited(
              HelperUtils.showSnackBarMessage(
                context,
                'receiptUploaded'.translate(context),
              ),
            );
            await context
                .read<FetchSubscriptionPackagesCubit>()
                .fetchPackages();
          } else {
            await HelperUtils.showSnackBarMessage(
              context,
              result['message'].toString(),
            );
          }
        } catch (e) {
          await HelperUtils.showSnackBarMessage(
            context,
            e.toString(),
          );
        }
      },
      buttonTitle: 'reUploadReceipt'.translate(context),
    );
  }
}

class MySeparator extends StatelessWidget {
  const MySeparator({
    super.key,
    this.height = 1,
    this.color = Colors.grey,
    this.isShimmer = false,
  });
  final double height;
  final Color color;
  final bool isShimmer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: isShimmer
                  ? CustomShimmer(
                      height: dashHeight,
                      width: dashWidth,
                      borderRadius: 0,
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(color: color),
                    ),
            );
          }),
        );
      },
    );
  }
}
