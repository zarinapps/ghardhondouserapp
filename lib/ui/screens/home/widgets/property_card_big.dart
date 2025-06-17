import 'dart:ui';

import 'package:ebroker/data/cubits/property/fetch_compare_properties_cubit.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/widgets/like_button_widget.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/utils/string_extenstion.dart';

class PropertyCardBig extends StatelessWidget {
  const PropertyCardBig({
    required this.property,
    required this.isFromCompare,
    this.sourceProperty,
    super.key,
    this.onLikeChange,
    this.isFirst,
    this.showEndPadding,
    this.showLikeButton,
    this.disableTap,
    this.showFeatured,
  });

  final PropertyModel property;
  final bool isFromCompare;
  final PropertyModel? sourceProperty;
  final bool? isFirst;
  final bool? showEndPadding;
  final bool? showLikeButton;
  final Function(FavoriteType type)? onLikeChange;
  final bool? disableTap;
  final bool? showFeatured;

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
    return GestureDetector(
      onTap: () async {
        if (isFromCompare) return;
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
                        packageType: SubscriptionPackageType.premiumProperties,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                      if (isPromoted || (showFeatured ?? false))
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
                            filter: ImageFilter.blur(),
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
                      top: 8,
                      bottom: 5,
                      left: 12,
                      right: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
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
                          if (isFromCompare) ...[
                            const SizedBox(
                              height: 10,
                            ),
                            UiUtils.buildButton(
                              context,
                              onPressed: () async {
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
                                              await checkPackage
                                                  .checkPackageAvailable(
                                            packageType:
                                                PackageType.premiumProperties,
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
                                              dialog:
                                                  const BlurredSubscriptionDialogBox(
                                                packageType:
                                                    SubscriptionPackageType
                                                        .premiumProperties,
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
                              buttonTitle: 'viewProperty'.translate(context),
                              buttonColor: context.color.primaryColor,
                              border: BorderSide(
                                color: context.color.tertiaryColor,
                              ),
                              radius: 10,
                              textColor: context.color.tertiaryColor,
                              height: 42.rh(context),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            UiUtils.buildButton(
                              context,
                              onPressed: () async {
                                try {
                                  unawaited(Widgets.showLoader(context));

                                  // Get a property to compare with
                                  final targetPropertyId = property.id!;

                                  // Fetch comparison data using the cubit
                                  final comparePropertiesCubit =
                                      FetchComparePropertiesCubit();
                                  await comparePropertiesCubit
                                      .fetchCompareProperties(
                                    sourcePropertyId: sourceProperty!.id!,
                                    targetPropertyId: targetPropertyId,
                                  );

                                  final state = comparePropertiesCubit.state;

                                  if (state is FetchComparePropertiesSuccess) {
                                    Widgets.hideLoder(context);
                                    final sourcePropertyData = sourceProperty;

                                    final targetPropertyData = property;

                                    // Navigate to compare property screen with the fetched data
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.comparePropertiesScreen,
                                      arguments: {
                                        'comparisionData':
                                            state.comparisionData,
                                        'category': property.category,
                                        'isSourcePremium': sourcePropertyData
                                                ?.allPropData['is_premium']
                                            as bool?,
                                        'isTargetPremium': targetPropertyData
                                                    .allPropData['is_premium']
                                                as bool? ??
                                            false,
                                        'isSourcePromoted':
                                            sourcePropertyData?.promoted ??
                                                false,
                                        'isTargetPromoted':
                                            targetPropertyData.promoted ??
                                                false,
                                      },
                                    );
                                  } else if (state
                                      is FetchComparePropertiesFailure) {
                                    Widgets.hideLoder(context);
                                    await HelperUtils.showSnackBarMessage(
                                      context,
                                      state.errorMessage,
                                      type: MessageType.error,
                                    );
                                  }
                                } catch (e) {
                                  Widgets.hideLoder(context);
                                  await HelperUtils.showSnackBarMessage(
                                    context,
                                    e.toString(),
                                    type: MessageType.error,
                                  );
                                } finally {
                                  Widgets.hideLoder(context);
                                }
                              },
                              buttonTitle: 'compareProperty'.translate(context),
                              radius: 10,
                              height: 42.rh(context),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (showLikeButton ?? true)
              PositionedDirectional(
                end: 20,
                top: 120,
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
