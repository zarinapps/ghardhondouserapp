import 'dart:ui';

import 'package:ebroker/data/cubits/delete_advertisment_cubit.dart';
import 'package:ebroker/data/cubits/project/fetch_my_promoted_projects.dart';
import 'package:ebroker/data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';

/// Base class for advertisement cards with common UI structure
abstract class BaseAdvertisementHorizontalCard extends StatelessWidget {
  const BaseAdvertisementHorizontalCard({
    super.key,
    this.statusButton,
    this.showDeleteButton,
    this.onDeleteTap,
    this.showLikeButton,
    this.additionalImageWidth,
  });

  final StatusButton? statusButton;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;

  // Abstract methods to be implemented by subclasses
  String get advertisementId;
  String get itemId;
  String get titleImage;
  String get itemType;
  String get categoryImage;
  String get categoryName;
  String get price;
  String get title;
  String get city;
  int get status;

  // Abstract methods for actions
  void onCardTap(BuildContext context);
  void onShareAction(BuildContext context);
  void onDeleteSuccess(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: GestureDetector(
        onLongPress: () => onShareAction(context),
        onTap: () => onCardTap(context),
        child: Container(
          height: 124,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1.5,
              color: context.color.borderColor,
            ),
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Row(
                children: [
                  _buildImageSection(context),
                  _buildInfoSection(context),
                ],
              ),
              if (showDeleteButton ?? false) _buildDeleteButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: UiUtils.getImage(
              titleImage,
              height: 121,
              width: 100 + (additionalImageWidth ?? 0),
              fit: BoxFit.cover,
            ),
          ),
          PositionedDirectional(
            bottom: 6,
            start: 6,
            child: Container(
              height: 19,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.color.secondaryColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  child: Center(
                    child: CustomText(
                      itemType.translate(context),
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
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                UiUtils.imageType(
                  categoryImage,
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
                    categoryName,
                    maxLines: 1,
                    fontWeight: FontWeight.w400,
                    fontSize: context.font.small.rf(context),
                    color: context.color.textLightColor,
                  ),
                ),
                if (statusButton != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 3,
                      horizontal: 3,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: statusButton!.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: 80,
                      height: 120 - 90 - 8,
                      child: Center(
                        child: CustomText(
                          statusButton!.lable,
                          fontWeight: FontWeight.bold,
                          fontSize: context.font.small,
                          color: statusButton?.textColor ?? Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (price.isNotEmpty) ...[
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
              const SizedBox(
                height: 5,
              ),
            ],
            CustomText(
              title.firstUpperCase(),
              maxLines: 1,
              fontSize: context.font.large,
              color: context.color.textColorDark,
            ),
            const SizedBox(
              height: 5,
            ),
            if (city.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: context.color.textLightColor,
                  ),
                  Expanded(
                    child: CustomText(
                      city.trim(),
                      maxLines: 1,
                      color: context.color.textLightColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return PositionedDirectional(
      bottom: 0,
      end: 0,
      child: BlocConsumer<DeleteAdvertismentCubit, DeleteAdvertismentState>(
        listener: (context, state) {
          if (state is DeleteAdvertismentSuccess) {
            onDeleteSuccess(context);
          }
        },
        builder: (
          BuildContext context,
          DeleteAdvertismentState state,
        ) {
          if (status != 1) {
            return SizedBox(
              height: 40,
              width: 32,
              child: SizedBox(width: 10.rw(context)),
            );
          }
          return GestureDetector(
            onTap: () {
              UiUtils.showBlurredDialoge(
                context,
                dialog: BlurredDialogBox(
                  title: UiUtils.translate(
                    context,
                    'deleteBtnLbl',
                  ),
                  onAccept: () async {
                    if (Constant.isDemoModeOn) {
                      await HelperUtils.showSnackBarMessage(
                        context,
                        UiUtils.translate(
                          context,
                          'thisActionNotValidDemo',
                        ),
                      );
                    } else {
                      await context.read<DeleteAdvertismentCubit>().delete(
                            advertisementId,
                          );
                    }
                  },
                  content: CustomText(
                    UiUtils.translate(
                      context,
                      'confirmDeleteAdvert',
                    ),
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsetsDirectional.only(
                bottom: 8,
                end: 8,
              ),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: context.color.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(33, 0, 0, 0),
                    offset: Offset(0, 2),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: (state is DeleteAdvertismentInProgress)
                  ? UiUtils.progress()
                  : SizedBox(
                      height: 24,
                      width: 24,
                      child: FittedBox(
                        fit: BoxFit.none,
                        child: SvgPicture.asset(
                          AppIcons.delete,
                          colorFilter: ColorFilter.mode(
                            context.color.error,
                            BlendMode.srcIn,
                          ),
                          width: 18,
                          height: 18,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

/// Advertisement Card For Property
class MyAdvertisementPropertyHorizontalCard
    extends BaseAdvertisementHorizontalCard {
  const MyAdvertisementPropertyHorizontalCard({
    required this.advertisement,
    super.key,
    super.statusButton,
    super.showDeleteButton,
    super.onDeleteTap,
    super.showLikeButton,
    super.additionalImageWidth,
  });

  final AdvertisementProperty? advertisement;

  @override
  String get advertisementId => advertisement!.id.toString();

  @override
  String get itemId => advertisement!.propertyId.toString();

  @override
  String get titleImage => advertisement!.property.titleImage;

  @override
  String get itemType => advertisement!.property.properyType;

  @override
  String get categoryImage => advertisement!.property.category.image;

  @override
  String get categoryName => advertisement!.property.category.category;

  @override
  String get price => advertisement!.property.price;

  @override
  String get title => advertisement!.property.title;

  @override
  String get city => advertisement!.property.city;

  @override
  int get status => advertisement!.status;

  @override
  void onShareAction(BuildContext context) {
    HelperUtils.share(
      context,
      advertisement!.id,
      advertisement!.propertyId.toString(),
    );
  }

  @override
  Future<void> onCardTap(BuildContext context) async {
    try {
      unawaited(Widgets.showLoader(context));
      final fetch = PropertyRepository();
      final dataOutput = await fetch.fetchPropertyFromPropertyId(
        id: advertisement!.propertyId,
        isMyProperty: true,
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
              'fromMyProperty': false,
            },
          );
        },
      );
    } catch (e) {
      Widgets.hideLoder(context);
    }
  }

  @override
  void onDeleteSuccess(BuildContext context) {
    context.read<FetchMyPromotedPropertysCubit>().delete(
          advertisement!.id,
        );
  }
}

/// Advertisement Card For project
class MyAdvertisementProjectHorizontalCard
    extends BaseAdvertisementHorizontalCard {
  const MyAdvertisementProjectHorizontalCard({
    required this.advertisement,
    super.key,
    super.statusButton,
    super.showDeleteButton,
    super.onDeleteTap,
    super.showLikeButton,
    super.additionalImageWidth,
  });

  final AdvertisementProject? advertisement;

  @override
  String get advertisementId => advertisement!.id.toString();

  @override
  String get itemId => advertisement!.projectId.toString();

  @override
  String get titleImage => advertisement!.project.titleImage;

  @override
  String get itemType => advertisement!.project.projectType;

  @override
  String get categoryImage => advertisement!.project.category.image;

  @override
  String get categoryName => advertisement!.project.category.category;

  @override
  String get price => '';

  @override
  String get title => advertisement!.project.title;

  @override
  String get city => advertisement!.project.city;

  @override
  int get status => advertisement!.status;

  @override
  void onShareAction(BuildContext context) {
    HelperUtils.share(
      context,
      advertisement!.id,
      advertisement!.projectId.toString(),
    );
  }

  @override
  Future<void> onCardTap(BuildContext context) async {
    try {
      unawaited(Widgets.showLoader(context));
      final projectRepository = ProjectRepository();
      final projectDetails = await projectRepository.getProjectDetails(
        id: advertisement!.project.id,
        isMyProject: true,
      );
      Future.delayed(
        Duration.zero,
        () {
          Widgets.hideLoder(context);
          HelperUtils.goToNextPage(
            Routes.projectDetailsScreen,
            context,
            false,
            args: {
              'project': projectDetails,
            },
          );
        },
      );
    } catch (e) {
      Widgets.hideLoder(context);
    }
  }

  @override
  void onDeleteSuccess(BuildContext context) {
    context.read<FetchMyPromotedProjectsCubit>().delete(
          advertisement!.id,
        );
  }
}
