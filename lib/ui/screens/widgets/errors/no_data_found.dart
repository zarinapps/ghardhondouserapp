import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({
    super.key,
    this.onTap,
    this.height,
    this.title,
    this.description,
  });
  final double? height;
  final VoidCallback? onTap;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            child: SvgPicture.asset(
              AppIcons.no_data_found,
              height: height ?? MediaQuery.of(context).size.height * 0.35,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          CustomText(
            title ?? 'nodatafound'.translate(context),
            fontWeight: FontWeight.w600,
            fontSize: context.font.extraLarge,
            color: context.color.tertiaryColor,
          ),
          const SizedBox(
            height: 14,
          ),
          CustomText(
            description ?? 'sorryLookingFor'.translate(context),
            textAlign: TextAlign.center,
            fontSize: context.font.large,
          ),
          const SizedBox(
            height: 14,
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: SizedBox(
                height: 50.rh(context),
                child: Center(
                  child: CustomText(
                    'retry'.translate(context),
                    fontWeight: FontWeight.bold,
                    fontSize: context.font.normal,
                    color: context.color.tertiaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
