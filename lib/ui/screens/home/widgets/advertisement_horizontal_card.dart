import 'dart:ui';

import 'package:ebroker/data/cubits/delete_advertisment_cubit.dart';
import 'package:ebroker/data/cubits/project/fetch_my_promoted_projects.dart';
import 'package:ebroker/data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';

/// Advertisement Card For Property, scroll down for project card
class MyAdvertisementPropertyHorizontalCard extends StatelessWidget {
  const MyAdvertisementPropertyHorizontalCard({
    required this.advertisement,
    super.key,
    this.statusButton,
    this.showDeleteButton,
    this.onDeleteTap,
    this.showLikeButton,
    this.additionalImageWidth,
  });
  final AdvertisementProperty? advertisement;
  final StatusButton? statusButton;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: GestureDetector(
        onLongPress: () {
          HelperUtils.share(
            context,
            advertisement!.id,
            advertisement!.propertyId.toString(),
          );
        },
        onTap: () async {
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
        },
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: UiUtils.getImage(
                            advertisement!.property.titleImage,
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
                              color: context.color.secondaryColor
                                  .withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 2,
                                sigmaY: 3,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Center(
                                  child: CustomText(
                                    advertisement!.property.properyType
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
                        left: 12,
                        right: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              UiUtils.imageType(
                                advertisement!.property.category.image,
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
                                  advertisement!.property.category.category,
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
                                        color: statusButton?.textColor ??
                                            Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          CustomText(
                            advertisement!.property.price.priceFormat(
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
                          CustomText(
                            advertisement!.property.title.firstUpperCase(),
                            maxLines: 1,
                            fontSize: context.font.large,
                            color: context.color.textColorDark,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          if (advertisement!.property.city != '')
                            Row(
                              children: [
                                UiUtils.getSvg(
                                  AppIcons.location,
                                ),
                                Expanded(
                                  child: CustomText(
                                    advertisement!.property.city.trim() ?? '',
                                    maxLines: 1,
                                    color: context.color.textLightColor,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (showDeleteButton ?? false)
                PositionedDirectional(
                  bottom: 0,
                  end: 0,
                  child: BlocConsumer<DeleteAdvertismentCubit,
                      DeleteAdvertismentState>(
                    listener: (context, state) {
                      if (state is DeleteAdvertismentSuccess) {
                        context.read<FetchMyPromotedPropertysCubit>().delete(
                              advertisement!.id,
                            );
                      }
                    },
                    builder: (
                      BuildContext context,
                      DeleteAdvertismentState state,
                    ) {
                      if (advertisement!.status != 1) {
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
                            dialoge: BlurredDialogBox(
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
                                  await context
                                      .read<DeleteAdvertismentCubit>()
                                      .delete(
                                        advertisement!.id,
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Advertisement Card For project
class MyAdvertisementProjectHorizontalCard extends StatelessWidget {
  const MyAdvertisementProjectHorizontalCard({
    required this.advertisement,
    super.key,
    this.statusButton,
    this.showDeleteButton,
    this.onDeleteTap,
    this.showLikeButton,
    this.additionalImageWidth,
  });
  final AdvertisementProject? advertisement;
  final StatusButton? statusButton;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final double? additionalImageWidth;
  final bool? showLikeButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: GestureDetector(
        onLongPress: () {
          HelperUtils.share(
            context,
            advertisement!.id,
            advertisement!.projectId.toString(),
          );
        },
        onTap: () async {
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
        },
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: UiUtils.getImage(
                            advertisement!.project.titleImage,
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
                              color: context.color.secondaryColor
                                  .withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 2,
                                sigmaY: 3,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Center(
                                  child: CustomText(
                                    advertisement!.project.projectType
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
                        left: 12,
                        right: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              UiUtils.imageType(
                                advertisement!.project.category.image,
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
                                  advertisement!.project.category.category,
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
                                        color: statusButton?.textColor ??
                                            Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          CustomText(
                            advertisement!.project.title.firstUpperCase(),
                            maxLines: 1,
                            fontSize: context.font.large,
                            color: context.color.textColorDark,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          if (advertisement!.project.city != '')
                            Row(
                              children: [
                                UiUtils.getSvg(
                                  AppIcons.location,
                                ),
                                Expanded(
                                  child: CustomText(
                                    advertisement!.project.city.trim(),
                                    maxLines: 1,
                                    color: context.color.textLightColor,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (showDeleteButton ?? false)
                PositionedDirectional(
                  bottom: 0,
                  end: 0,
                  child: BlocConsumer<DeleteAdvertismentCubit,
                      DeleteAdvertismentState>(
                    listener: (context, state) {
                      if (state is DeleteAdvertismentSuccess) {
                        context.read<FetchMyPromotedProjectsCubit>().delete(
                              advertisement!.id,
                            );
                      }
                    },
                    builder: (
                      BuildContext context,
                      DeleteAdvertismentState state,
                    ) {
                      if (advertisement!.status != 1) {
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
                            dialoge: BlurredDialogBox(
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
                                  await context
                                      .read<DeleteAdvertismentCubit>()
                                      .delete(
                                        advertisement!.id,
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
