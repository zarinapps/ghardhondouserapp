import 'dart:ui';

import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/like_button_widget.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';

class PropertyCardBig extends StatelessWidget {
  const PropertyCardBig({
    required this.property,
    super.key,
    this.onLikeChange,
    this.isFirst,
    this.showEndPadding,
    this.showLikeButton,
  });

  final PropertyModel property;
  final bool? isFirst;
  final bool? showEndPadding;
  final bool? showLikeButton;
  final Function(FavoriteType type)? onLikeChange;

  @override
  Widget build(BuildContext context) {
    var rentPrice = property.price!.priceFormat(
      enabled: Constant.isNumberWithSuffix == true,
      context: context,
    );
    if (property.rentduration != '' && property.rentduration != null) {
      rentPrice =
          ('$rentPrice / ') + (property.rentduration ?? '').translate(context);
    }
    final isPremium = property.allPropData['is_premium'] as bool? ?? false;
    final isPromoted = property.promoted ?? false;
    final isAddedByMe = property.addedBy.toString() == HiveUtils.getUserId();
    return GestureDetector(
      onTap: () async {
        try {
          unawaited(Widgets.showLoader(context));
          if (isPremium) {
            GuestChecker.check(
              onNotGuest: () async {
                if (isAddedByMe) {
                  final fetch = PropertyRepository();
                  final dataOutput = await fetch.fetchPropertyFromPropertyId(
                    id: property.id!,
                    isMyProperty: isAddedByMe,
                  );
                  Future.delayed(
                    Duration.zero,
                    () {
                      Widgets.hideLoder(context);
                      HelperUtils.goToNextPage(
                        Routes.propertyDetails,
                        context,
                        false,
                        args: {
                          'propertyData': dataOutput,
                        },
                      );
                    },
                  );
                } else {
                  final checkPackage = CheckPackage();
                  final packageAvailable =
                      await checkPackage.checkPackageAvailable(
                    packageType: PackageType.premiumProperties,
                  );
                  if (packageAvailable) {
                    final fetch = PropertyRepository();
                    final dataOutput = await fetch.fetchPropertyFromPropertyId(
                      id: property.id!,
                      isMyProperty: isAddedByMe,
                    );
                    Future.delayed(
                      Duration.zero,
                      () {
                        Widgets.hideLoder(context);
                        HelperUtils.goToNextPage(
                          Routes.propertyDetails,
                          context,
                          false,
                          args: {
                            'propertyData': dataOutput,
                          },
                        );
                      },
                    );
                  } else {
                    Widgets.hideLoder(context);
                    await UiUtils.showBlurredDialoge(
                      context,
                      dialoge: const BlurredSubscriptionDialogBox(
                        packageType: SubscriptionPackageType.premiumProperties,
                        isAcceptContainesPush: true,
                      ),
                    );
                  }
                }
              },
            );
          } else {
            final fetch = PropertyRepository();
            final dataOutput = await fetch.fetchPropertyFromPropertyId(
              id: property.id!,
              isMyProperty: isAddedByMe,
            );
            Future.delayed(
              Duration.zero,
              () {
                Widgets.hideLoder(context);
                HelperUtils.goToNextPage(
                  Routes.propertyDetails,
                  context,
                  false,
                  args: {
                    'propertyData': dataOutput,
                  },
                );
              },
            );
          }
        } catch (e) {
          Widgets.hideLoder(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.color.secondaryColor,
          border: Border.all(
            width: 1.5,
            color: context.color.borderColor,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 147,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: UiUtils.getImage(
                          property.titleImage!,
                          height: 147,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          blurHash: property.titleimagehash,
                        ),
                      ),
                      if (isPremium)
                        PositionedDirectional(
                          start: 10,
                          top: 10,
                          child: UiUtils.getSvg(
                            height: 24,
                            width: 24,
                            AppIcons.premium,
                          ),
                        ),
                      if (isPromoted)
                        PositionedDirectional(
                          start: isPremium ? 39 : 10,
                          top: 10,
                          child: const PromotedCard(
                            type: PromoteCardType.icon,
                          ),
                        ),
                      PositionedDirectional(
                        start: 10,
                        bottom: 10,
                        child: Container(
                          height: 24,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: context.color.secondaryColor.withValues(
                              alpha: 0.7,
                            ),
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Center(
                                child: CustomText(
                                  property.properyType!
                                      .toLowerCase()
                                      .translate(context),
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.font.smaller,
                                  color: context.color.textColorDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                      left: 12,
                      right: 12,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            UiUtils.imageType(
                              property.category!.image!,
                              width: 18,
                              height: 18,
                              color: Constant.adaptThemeColorSvg
                                  ? context.color.tertiaryColor
                                  : null,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Flexible(
                              child: CustomText(
                                property.category?.category ?? '',
                                fontWeight: FontWeight.w400,
                                fontSize: context.font.large,
                                color: context.color.textLightColor,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        if (property.properyType.toString().toLowerCase() ==
                            'rent') ...[
                          CustomText(
                            rentPrice,
                            maxLines: 1,
                            fontWeight: FontWeight.w700,
                            fontSize: context.font.large,
                            color: context.color.tertiaryColor,
                          ),
                        ] else ...[
                          CustomText(
                            property.price!.priceFormat(
                              enabled: Constant.isNumberWithSuffix == true,
                              context: context,
                            ),
                            maxLines: 1,
                            fontWeight: FontWeight.w700,
                            fontSize: context.font.large,
                            color: context.color.tertiaryColor,
                          ),
                        ],
                        CustomText(
                          property.title ?? '',
                          maxLines: 1,
                          fontSize: context.font.larger,
                          fontWeight: FontWeight.w400,
                          color: context.color.textColorDark,
                        ),
                        if (property.city != '') ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                UiUtils.getSvg(
                                  AppIcons.location,
                                  height: 18,
                                  width: 18,
                                  color: context.color.textColorDark,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: CustomText(
                                    property.city!,
                                    maxLines: 1,
                                    color: context.color.textLightColor,
                                    fontSize: context.font.small,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (showLikeButton ?? true)
              PositionedDirectional(
                end: 25,
                top: 128,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(33, 0, 0, 0),
                        offset: Offset(0, 2),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: LikeButtonWidget(
                    propertyId: property.id!,
                    isFavourite: property.isFavourite!,
                    onLikeChanged: onLikeChange,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
