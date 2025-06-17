// Country picker widget to encapsulate country selection functionality
import 'package:ebroker/ui/screens/auth/login_screen.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class CountryPickerWidget extends StatelessWidget {
  const CountryPickerWidget({
    required this.flagEmoji,
    required this.onTap,
    super.key,
    this.isRTL = false,
  });
  final String? flagEmoji;
  final VoidCallback onTap;
  final bool isRTL;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: isRTL ? BoxFit.none : BoxFit.scaleDown,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsetsDirectional.only(
            start: isRTL ? 0 : UIConstants.spacingM,
            end: isRTL ? UIConstants.spacingM : 0,
          ),
          height: UIConstants.countryPickerHeight,
          alignment: Alignment.center,
          child: Row(
            children: [
              CustomText(
                flagEmoji ?? '',
                fontSize: context.font.xxLarge,
              ),
              const SizedBox(width: UIConstants.spacingXS),
              UiUtils.getSvg(
                height: 12,
                AppIcons.downArrow,
                color: context.color.tertiaryColor,
              ),
              const SizedBox(width: UIConstants.spacingXS),
            ],
          ),
        ),
      ),
    );
  }
}
