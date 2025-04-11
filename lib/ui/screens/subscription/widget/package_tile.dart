import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/payment/in_app_purchase/inAppPurchaseManager.dart';
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

  Widget buildPriceAndSubscribe() {
    return Container(
      margin: const EdgeInsets.only(top: 18, bottom: 18, left: 16, right: 16),
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
                '${widget.package.duration} ${'days'.translate(context)}',
                fontSize: context.font.large,
                color: context.color.tertiaryColor,
              ),
            ],
          ),
          const Spacer(),
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
            '${'validUntil'.translate(context)} $duration ${'days'.translate(context)}',
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
}

class MySeparator extends StatelessWidget {
  const MySeparator({super.key, this.height = 1, this.color = Colors.grey});
  final double height;
  final Color color;

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
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class WavePattern extends CustomPainter {
  WavePattern({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Define wave dimensions
    final waveWidth = size.width / 14;
    const waveHeight = 6.0;
    const cornerRadius = 15.0;

    // Start path from top-left with rounded corner
    path
      ..moveTo(cornerRadius, 0)

      // Top edge with rounded corners
      ..lineTo(size.width - cornerRadius, 0)
      ..arcToPoint(
        Offset(size.width, cornerRadius),
        radius: const Radius.circular(cornerRadius),
      )

      // Right edge
      ..lineTo(size.width, size.height - waveHeight);

    // Draw curved waves
    var currentX = size.width;

    // Starting point for waves
    path.lineTo(currentX, size.height - waveHeight);

    while (currentX > 0) {
      // First outward curve
      path.quadraticBezierTo(
        currentX - waveWidth / 4, size.height - waveHeight * 2,
        // control point higher up
        currentX - waveWidth / 2, size.height - waveHeight, // end point
      );

      currentX -= waveWidth / 2;

      if (currentX > 0) {
        // Second outward curve
        path.quadraticBezierTo(
          currentX - waveWidth / 4, size.height, // control point lower down
          currentX - waveWidth / 2, size.height - waveHeight, // end point
        );

        currentX -= waveWidth / 2;
      }
    }

    // Complete the path
    path
      ..lineTo(0, size.height - waveHeight)
      ..lineTo(0, cornerRadius)
      ..arcToPoint(
        const Offset(cornerRadius, 0),
        radius: const Radius.circular(cornerRadius),
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
