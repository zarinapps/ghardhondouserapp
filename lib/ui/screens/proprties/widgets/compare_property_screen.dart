import 'dart:ui';

import 'package:ebroker/data/model/compare_property_model.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ComparePropertyScreen extends StatefulWidget {
  const ComparePropertyScreen({
    required this.comparisionData,
    required this.category,
    required this.isSourcePremium,
    required this.isTargetPremium,
    required this.isSourcePromoted,
    required this.isTargetPromoted,
    super.key,
  });
  final ComparePropertyModel comparisionData;
  final Categorys category;
  final bool isSourcePremium;
  final bool isTargetPremium;
  final bool isSourcePromoted;
  final bool isTargetPromoted;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => ComparePropertyScreen(
        comparisionData: arguments?['comparisionData'] as ComparePropertyModel,
        isSourcePremium: arguments?['isSourcePremium'] as bool,
        isTargetPremium: arguments?['isTargetPremium'] as bool,
        isSourcePromoted: arguments?['isSourcePromoted'] as bool,
        isTargetPromoted: arguments?['isTargetPromoted'] as bool,
        category: arguments?['category'] as Categorys,
      ),
    );
  }

  @override
  ComparePropertyScreenState createState() => ComparePropertyScreenState();
}

class ComparePropertyScreenState extends State<ComparePropertyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: 'Compare Property',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Property cards row
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPropertyCard(
                      title: widget.comparisionData.sourceProperty?.title ?? '',
                      image:
                          widget.comparisionData.sourceProperty?.titleImage ??
                              '',
                      price: widget.comparisionData.sourceProperty?.price ?? '',
                      location:
                          widget.comparisionData.sourceProperty?.address ?? '',
                      propertyType:
                          widget.comparisionData.sourceProperty?.propertyType ??
                              '',
                      categoryName: widget.category.category ?? '',
                      categoryIcon: widget.category.image ?? '',
                      isPremium: widget.isSourcePremium,
                      isPromoted: widget.isSourcePromoted,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPropertyCard(
                      title: widget.comparisionData.targetProperty?.title ?? '',
                      image:
                          widget.comparisionData.targetProperty?.titleImage ??
                              '',
                      price: widget.comparisionData.targetProperty?.price ?? '',
                      location:
                          widget.comparisionData.targetProperty?.address ?? '',
                      propertyType:
                          widget.comparisionData.targetProperty?.propertyType ??
                              '',
                      categoryName: widget.category.category ?? '',
                      categoryIcon: widget.category.image ?? '',
                      isPremium: widget.isTargetPremium,
                      isPromoted: widget.isTargetPromoted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Table with custom-colored rows
            _buildComparisonTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(BuildContext context) {
    final rows = _buildComparisonRows(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.borderColor),
      ),
      child: Column(
        children: [
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: context.color.tertiaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomText(
                    'details'.translate(context),
                    fontWeight: FontWeight.bold,
                    color: context.color.secondaryColor,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: CustomText(
                    widget.comparisionData.sourceProperty?.title ?? '',
                    maxLines: 1,
                    fontWeight: FontWeight.bold,
                    color: context.color.secondaryColor,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: CustomText(
                    widget.comparisionData.targetProperty?.title ?? '',
                    maxLines: 1,
                    fontWeight: FontWeight.bold,
                    color: context.color.secondaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Content rows with alternating colors
          ...List.generate(rows.length, (index) {
            final isEven = index.isEven;
            final rowData = rows[index];

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: isEven
                    ? context.color.secondaryColor
                    : Color.lerp(
                        context.color.secondaryColor,
                        context.color.tertiaryColor,
                        0.1,
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: CustomText(
                        rowData['title'] ?? '',
                        fontWeight: FontWeight.bold,
                        fontSize: context.font.small,
                        color: context.color.textColorDark,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: CustomText(
                      rowData['source'] ?? '',
                      fontSize: context.font.small,
                      color: context.color.textColorDark,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: CustomText(
                      rowData['target'] ?? '',
                      fontSize: context.font.small,
                      color: context.color.textColorDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Map<String, String>> _buildComparisonRows(BuildContext context) {
    final sourceProperty = widget.comparisionData.sourceProperty;
    final targetProperty = widget.comparisionData.targetProperty;

    // Basic property details comparison
    final rows = <Map<String, String>>[
      {
        'title': 'location'.translate(context),
        'source':
            '${sourceProperty?.city ?? ''}, ${sourceProperty?.state ?? ''}, ${sourceProperty?.country ?? ''}',
        'target':
            '${targetProperty?.city ?? ''}, ${targetProperty?.state ?? ''}, ${targetProperty?.country ?? ''}',
      },
      {
        'title': 'propertyType'.translate(context),
        'source':
            sourceProperty?.propertyType?.toLowerCase().translate(context) ??
                '',
        'target':
            targetProperty?.propertyType?.toLowerCase().translate(context) ??
                '',
      },
      if (sourceProperty?.createdAt != '' ||
          targetProperty?.createdAt != '') ...[
        {
          'title': 'createdDate'.translate(context),
          'source': sourceProperty?.createdAt ?? '',
          'target': targetProperty?.createdAt ?? '',
        },
      ],
      {
        'title': 'totalLikes'.translate(context),
        'source': sourceProperty?.totalLikes?.toString() ?? '0',
        'target': targetProperty?.totalLikes?.toString() ?? '0',
      },
      {
        'title': 'totalViews'.translate(context),
        'source': sourceProperty?.totalViews?.toString() ?? '0',
        'target': targetProperty?.totalViews?.toString() ?? '0',
      },
    ];

    // Add facilities comparison
    final allFacilityIds = <int>{};

    // Collect all unique facility IDs from both properties
    sourceProperty?.facilities?.forEach((facility) {
      if (facility.id != null) allFacilityIds.add(facility.id!);
    });

    targetProperty?.facilities?.forEach((facility) {
      if (facility.id != null) allFacilityIds.add(facility.id!);
    });

// Add facility rows
    for (final facilityId in allFacilityIds) {
      final sourceFacility = sourceProperty?.facilities?.firstWhere(
        (f) => f.id == facilityId,
        orElse: Facilities.new,
      );

      final targetFacility = targetProperty?.facilities?.firstWhere(
        (f) => f.id == facilityId,
        orElse: Facilities.new,
      );

      if (sourceFacility?.name != null || targetFacility?.name != null) {
        // Format the source value
        var sourceValue = sourceFacility?.value ?? 'N/A';
        if (sourceValue.startsWith('[') && sourceValue.endsWith(']')) {
          sourceValue = sourceValue.substring(1, sourceValue.length - 1);
        }

        // Format the target value
        var targetValue = targetFacility?.value ?? 'N/A';
        if (targetValue.startsWith('[') && targetValue.endsWith(']')) {
          targetValue = targetValue.substring(1, targetValue.length - 1);
        }

        rows.add({
          'title': sourceFacility?.name ?? targetFacility?.name ?? '',
          'source': sourceValue,
          'target': targetValue,
        });
      }
    }

    // Add nearby places comparison
    final allNearbyPlaceIds = <int>{};

    // Collect all unique nearby place IDs
    sourceProperty?.nearByPlaces?.forEach((place) {
      if (place.id != null) allNearbyPlaceIds.add(place.id!);
    });

    targetProperty?.nearByPlaces?.forEach((place) {
      if (place.id != null) allNearbyPlaceIds.add(place.id!);
    });

    // Add nearby place rows
    for (final placeId in allNearbyPlaceIds) {
      final sourcePlace = sourceProperty?.nearByPlaces?.firstWhere(
        (p) => p.id == placeId,
        orElse: NearByPlaces.new,
      );

      final targetPlace = targetProperty?.nearByPlaces?.firstWhere(
        (p) => p.id == placeId,
        orElse: NearByPlaces.new,
      );

      if (sourcePlace?.name != null || targetPlace?.name != null) {
        rows.add({
          'title': '${sourcePlace?.name ?? targetPlace?.name ?? ''} Distance',
          'source': sourcePlace?.distance != null
              ? '${sourcePlace!.distance} km'
              : 'N/A',
          'target': targetPlace?.distance != null
              ? '${targetPlace!.distance} km'
              : 'N/A',
        });
      }
    }

    return rows;
  }

  Widget _buildPropertyCard({
    required String title,
    required String image,
    required String price,
    required String location,
    required String propertyType,
    required String categoryName,
    required String categoryIcon,
    required bool isPremium,
    required bool isPromoted,
  }) {
    // Use a more flexible height approach
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.33,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.color.secondaryColor,
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // This allows the column to size based on content
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with fixed height
          SizedBox(
            height: 142,
            width: double.infinity,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: UiUtils.getImage(
                    image,
                    height: 142,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    blurHash: '',
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
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Center(
                          child: CustomText(
                            propertyType.toLowerCase().translate(context),
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
          // Details section with flexible height
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    UiUtils.imageType(
                      categoryIcon,
                      width: 18,
                      height: 18,
                      color: Constant.adaptThemeColorSvg
                          ? context.color.tertiaryColor
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomText(
                        categoryName,
                        fontWeight: FontWeight.w400,
                        fontSize: context.font.large,
                        color: context.color.textColorDark,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (propertyType.toLowerCase() == 'rent') ...[
                  CustomText(
                    price,
                    maxLines: 1,
                    fontWeight: FontWeight.w700,
                    fontSize: context.font.large,
                    color: context.color.tertiaryColor,
                  ),
                ] else ...[
                  CustomText(
                    price.priceFormat(
                      enabled: Constant.isNumberWithSuffix == true,
                      context: context,
                    ),
                    maxLines: 1,
                    fontWeight: FontWeight.w700,
                    fontSize: context.font.large,
                    color: context.color.tertiaryColor,
                  ),
                ],
                const SizedBox(height: 6),
                CustomText(
                  title,
                  maxLines: 1,
                  fontSize: context.font.larger,
                  fontWeight: FontWeight.w400,
                  color: context.color.textColorDark,
                ),
                if (location != '') ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UiUtils.getSvg(
                        AppIcons.location,
                        height: 18,
                        width: 18,
                        color: context.color.textColorDark,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: CustomText(
                          location,
                          maxLines: 1,
                          color: context.color.textColorDark,
                          fontSize: context.font.small,
                          fontWeight: FontWeight.w400,
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
    );
  }
}
