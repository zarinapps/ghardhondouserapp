import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key, this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.secondaryColor,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                child: UiUtils.getSvg(AppIcons.no_internet),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomText(
                'noInternet'.translate(context),
                fontWeight: FontWeight.w600,
                fontSize: context.font.extraLarge,
                color: context.color.tertiaryColor,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomText(
                UiUtils.translate(context, 'noInternetErrorMsg'),
                textAlign: TextAlign.center,
                maxLines: 5,
              ),
              const SizedBox(
                height: 5,
              ),
              TextButton(
                onPressed: onRetry,
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(
                    context.color.tertiaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: CustomText(
                  UiUtils.translate(context, 'retry'),
                  color: context.color.tertiaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
