// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:ui';

import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/like_button_widget.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';

class PropertyHorizontalCard extends StatelessWidget {
  final PropertyModel property;
  final AdvertisementProperty? advertisement;
  final List<PropertyModel>? properties;
  final double? additionalHeight;
  final StatusButton? statusButton;
  final bool? showDeleteButton;
  final double? additionalImageWidth;
  final bool? showLikeButton;
  final bool? isFromSearch;
  final bool? isFromMyProperty;
  final bool? disableTap;
  final bool? showFeatured;

  const PropertyHorizontalCard({
    required this.property,
    this.advertisement,
    this.properties,
    super.key,
    this.additionalHeight,
    this.statusButton,
    this.showDeleteButton,
    this.showLikeButton,
    this.additionalImageWidth,
    this.isFromSearch,
    this.isFromMyProperty,
    this.disableTap,
    this.showFeatured,
  });

  @override
  Widget build(BuildContext context) {
    var rentPrice = property.price!.priceFormat(
      enabled: Constant.isNumberWithSuffix == true,
      context: context,
    );

    if (property.rentduration != '' && property.rentduration != null) {
      rentPrice =
          '$rentPrice / ${(property.rentduration ?? '').translate(context)}';
    }

    final isPremium = property.allPropData['is_premium'] as bool? ?? false;
    final isPromoted = property.promoted ?? false;
    final isAddedByMe = property.addedBy.toString() == HiveUtils.getUserId();
    return BlocProvider(
      create: (context) => AddToFavoriteCubitCubit(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.5),
        child: GestureDetector(
          onLongPress: () {
            HelperUtils.share(context, property.id!, property.slugId ?? '');
          },
          onTap: () async {
            if (disableTap ?? false) return;
            try {
              if (isPremium) {
                await GuestChecker.check(
                  onNotGuest: () async {
                    unawaited(Widgets.showLoader(context));

                    if (isAddedByMe) {
                      await _navigateToPropertyDetails(
                        context,
                        property.id!,
                        isAddedByMe,
                      );
                    } else {
                      final checkPackage = CheckPackage();
                      final packageAvailable =
                          await checkPackage.checkPackageAvailable(
                        packageType: PackageType.premiumProperties,
                      );
                      if (packageAvailable) {
                        await _navigateToPropertyDetails(
                          context,
                          property.id!,
                          isAddedByMe,
                        );
                      } else {
                        Widgets.hideLoder(context);

                        await UiUtils.showBlurredDialoge(
                          context,
                          dialog: const BlurredSubscriptionDialogBox(
                            packageType:
                                SubscriptionPackageType.premiumProperties,
                            isAcceptContainesPush: true,
                          ),
                        );
                      }
                    }
                  },
                );
              } else {
                unawaited(Widgets.showLoader(context));

                await _navigateToPropertyDetails(
                  context,
                  property.id!,
                  isAddedByMe,
                );
              }
            } catch (e) {
              // Error handled in the finally block
            } finally {
              Widgets.hideLoder(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            height: isPromoted ? 124 : (124 + (additionalHeight ?? 0)),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.5,
                color: context.color.borderColor,
              ),
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: UiUtils.getImage(
                                height: isPromoted ? 100 : 121,
                                width: 100,
                                property.titleImage ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (isPremium)
                              PositionedDirectional(
                                start: 6,
                                top: 6,
                                child: UiUtils.getSvg(
                                  AppIcons.premium,
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            PositionedDirectional(
                              start: 6,
                              bottom: 6,
                              child: Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color:
                                      context.color.secondaryColor.withValues(
                                    alpha: 0.7,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    4,
                                  ),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
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
                      if (isPromoted || (showFeatured ?? false)) ...[
                        const SizedBox(height: 4),
                        const PromotedCard(
                          type: PromoteCardType.icon,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UiUtils.imageType(
                            property.category?.image ?? '',
                            width: 18,
                            height: 18,
                            color: Constant.adaptThemeColorSvg
                                ? context.color.tertiaryColor
                                : null,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: CustomText(
                              property.category?.category ?? '',
                              maxLines: 1,
                              fontWeight: FontWeight.w400,
                              fontSize: context.font.small.rf(context),
                              color: context.color.textLightColor,
                            ),
                          ),
                          if (showLikeButton ?? true)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: context.color.secondaryColor,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromARGB(12, 0, 0, 0),
                                    offset: Offset(0, 2),
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: LikeButtonWidget(
                                propertyId: property.id!,
                                isFavourite: property.isFavourite!,
                                onLikeChanged: (type) async {
                                  if (type == FavoriteType.add) {
                                    context
                                        .read<FetchFavoritesCubit>()
                                        .add(property);
                                  } else {
                                    context
                                        .read<FetchFavoritesCubit>()
                                        .remove(property.id);
                                  }
                                },
                              ),
                            ),
                          if (showLikeButton == false && statusButton == null)
                            const SizedBox(
                              width: 32,
                              height: 32,
                              child: SizedBox(
                                height: 32,
                                width: 32,
                              ),
                            ),
                          if (statusButton != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: 3,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: statusButton!.color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: CustomText(
                                        statusButton!.lable,
                                        fontWeight: FontWeight.bold,
                                        fontSize: context.font.small,
                                        color: statusButton?.textColor ??
                                            Colors.black,
                                      ),
                                    ),
                                    if (property.requestStatus.toString() ==
                                        'rejected') ...[
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          UiUtils.showBlurredDialoge(
                                            context,
                                            dialog: BlurredDialogBox(
                                              acceptTextColor:
                                                  context.color.buttonColor,
                                              showCancleButton: false,
                                              title: statusButton!.lable,
                                              content: CustomText(
                                                property.rejectReason?.reason
                                                        .toString() ??
                                                    '',
                                              ),
                                            ),
                                          );
                                        },
                                        child: UiUtils.getSvg(
                                          AppIcons.info,
                                          width: 20,
                                          height: 20,
                                          color: statusButton!.textColor,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
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
                        property.title!.firstUpperCase(),
                        maxLines: 1,
                        fontSize: context.font.large,
                        color: context.color.textColorDark,
                      ),
                      if (property.city != '') ...[
                        const Spacer(),
                        Row(
                          children: [
                            UiUtils.getSvg(
                              AppIcons.location,
                            ),
                            Expanded(
                              child: CustomText(
                                property.city?.trim() ?? '',
                                maxLines: 1,
                                color: context.color.textLightColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToPropertyDetails(
    BuildContext context,
    int propertyId,
    bool isMyProperty,
  ) async {
    final fetch = PropertyRepository();
    final dataOutput = await fetch.fetchPropertyFromPropertyId(
      id: propertyId,
      isMyProperty: isMyProperty,
    );

    Widgets.hideLoder(context);

    Future.delayed(
      Duration.zero,
      () {
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
}

class StatusButton {
  final String lable;
  final Color color;
  final Color? textColor;

  StatusButton({
    required this.lable,
    required this.color,
    this.textColor,
  });
}
