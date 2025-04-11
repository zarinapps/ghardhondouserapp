import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class ProjectHorizontalCard extends StatelessWidget {
  const ProjectHorizontalCard({
    required this.project,
    super.key,
    this.useRow,
    this.statusButton,
    this.addBottom,
    this.additionalHeight,
    this.additionalImageWidth,
  });
  final ProjectModel project;
  final List<Widget>? addBottom;
  final StatusButton? statusButton;
  final double? additionalHeight;
  final bool? useRow;
  final double? additionalImageWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: GestureDetector(
        onTap: () async {
          try {
            GuestChecker.check(
              onNotGuest: () async {
                unawaited(Widgets.showLoader(context));

                if (project.addedBy.toString() == HiveUtils.getUserId()) {
                  try {
                    unawaited(Widgets.showLoader(context));
                    final projectRepository = ProjectRepository();
                    final projectDetails = await projectRepository
                        .getProjectDetails(id: project.id!, isMyProject: true);
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
                } else if (project.addedBy.toString() !=
                    HiveUtils.getUserId()) {
                  final checkPackage = CheckPackage();

                  final packageAvailable =
                      await checkPackage.checkPackageAvailable(
                    packageType: PackageType.projectAccess,
                  );
                  if (packageAvailable) {
                    try {
                      unawaited(Widgets.showLoader(context));
                      final projectRepository = ProjectRepository();
                      final projectDetails =
                          await projectRepository.getProjectDetails(
                        id: project.id!,
                        isMyProject: false,
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
                  } else {
                    await UiUtils.showBlurredDialoge(
                      context,
                      dialoge: const BlurredSubscriptionDialogBox(
                        packageType: SubscriptionPackageType.projectAccess,
                        isAcceptContainesPush: true,
                      ),
                    );
                    Widgets.hideLoder(context);
                  }
                }
                Widgets.hideLoder(context);
              },
            );
            Widgets.hideLoder(context);
          } catch (e) {
            Widgets.hideLoder(context);
          } finally {
            Widgets.hideLoder(context);
          }
        },
        child: Container(
          height: addBottom == null ? 115 : (115 + (additionalHeight ?? 0)),
          decoration: BoxDecoration(
            border: Border.all(width: 1.5, color: context.color.borderColor),
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Stack(
                            children: [
                              UiUtils.getImage(
                                project.image ?? '',
                                height: 111,
                                width: 100 + (additionalImageWidth ?? 0),
                                fit: BoxFit.cover,
                              ),
                              PositionedDirectional(
                                start: 5,
                                top: 5,
                                child: UiUtils.getSvg(
                                  AppIcons.premium,
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              if (project.isPromoted ?? false)
                                PositionedDirectional(
                                  bottom: 0,
                                  end: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.color.tertiaryColor,
                                      borderRadius:
                                          const BorderRadiusDirectional.only(
                                        topStart: Radius.circular(18),
                                        bottomEnd: Radius.circular(18),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3),
                                      child: Center(
                                        child: CustomText(
                                          UiUtils.translate(
                                            context,
                                            'featured',
                                          ),
                                          fontWeight: FontWeight.w600,
                                          color: context.color.buttonColor,
                                          fontSize: context.font.small,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              // CustomText(property.promoted.toString()),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 5,
                          left: 12,
                          bottom: 5,
                          right: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                UiUtils.imageType(
                                  project.category!.image ?? '',
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
                                  flex: 3,
                                  child: CustomText(
                                    project.category!.category!,
                                    maxLines: 1,
                                    fontWeight: FontWeight.w400,
                                    fontSize: context.font.small.rf(context),
                                    color: context.color.textLightColor,
                                  ),
                                ),
                                if (statusButton == null) ...[
                                  const Spacer(),
                                  buildProjectType(context, project),
                                ],
                                if (statusButton != null) ...[
                                  const Spacer(),
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
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  project.title!.firstUpperCase(),
                                  maxLines: 1,
                                  fontSize: context.font.large,
                                  color: context.color.textColorDark,
                                ),
                                CustomText(
                                  project.description!.firstUpperCase(),
                                  maxLines: 1,
                                  fontSize: context.font.small,
                                  color: context.color.textColorDark
                                      .withValues(alpha: 0.80),
                                ),
                              ],
                            ),
                            if (project.city != '')
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: context.color.textLightColor,
                                  ),
                                  Expanded(
                                    child: CustomText(
                                      project.city?.trim() ?? '',
                                      maxLines: 1,
                                      color: context.color.textLightColor,
                                    ),
                                  ),
                                  if (statusButton != null)
                                    buildProjectType(context, project),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (useRow == false || useRow == null) ...addBottom ?? [],

              if (useRow == true) ...{Row(children: addBottom ?? [])},

              // ...addBottom ?? []
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildProjectType(BuildContext context, ProjectModel project) {
  return Container(
    height: 19,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: context.color.buttonColor.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: Center(
        child: CustomText(
          project.type!.translate(context),
          fontWeight: FontWeight.bold,
          fontSize: context.font.smaller,
          color: context.color.textColorDark,
        ),
      ),
    ),
  );
}
