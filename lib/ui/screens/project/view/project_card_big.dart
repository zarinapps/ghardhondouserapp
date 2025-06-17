import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';

class ProjectCardBig extends StatelessWidget {
  const ProjectCardBig({
    required this.project,
    this.color,
    this.disableTap,
    this.showFeatured,
    super.key,
  });
  final ProjectModel project;
  final Color? color;
  final bool? disableTap;
  final bool? showFeatured;

  @override
  Widget build(BuildContext context) {
    final isMyProject = project.addedBy.toString() == HiveUtils.getUserId();
    return GestureDetector(
      onTap: () async {
        if (disableTap ?? false) return;

        try {
          await GuestChecker.check(
            onNotGuest: () async {
              if (!isMyProject) {
                unawaited(Widgets.showLoader(context));

                // Check package availability for non-owner users
                final checkPackage = CheckPackage();
                final packageAvailable =
                    await checkPackage.checkPackageAvailable(
                  packageType: PackageType.projectAccess,
                );

                if (!packageAvailable) {
                  Widgets.hideLoder(context);
                  await UiUtils.showBlurredDialoge(
                    context,
                    dialog: const BlurredSubscriptionDialogBox(
                      packageType: SubscriptionPackageType.projectAccess,
                      isAcceptContainesPush: true,
                    ),
                  );
                  return;
                }
              }

              try {
                final projectRepository = ProjectRepository();
                final projectDetails =
                    await projectRepository.getProjectDetails(
                  id: project.id!,
                  isMyProject: isMyProject,
                );

                Widgets.hideLoder(context);
                HelperUtils.goToNextPage(
                  Routes.projectDetailsScreen,
                  context,
                  false,
                  args: {
                    'project': projectDetails,
                  },
                );
              } catch (e) {
                // Error handled in the finally block
                Widgets.hideLoder(context);
              }
            },
          );
        } catch (e) {
          // Error handled in the finally block
        } finally {
          Widgets.hideLoder(context);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color ?? context.color.secondaryColor,
          border: Border.all(
            width: 1.5,
            color: context.color.borderColor,
          ),
        ),
        child: Column(
          children: [
            Flexible(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: UiUtils.getImage(
                      project.image ?? '',
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,
                      blurHash: project.image ?? '',
                    ),
                  ),
                  PositionedDirectional(
                    start: 10,
                    top: 10,
                    child: UiUtils.getSvg(
                      AppIcons.premium,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  if ((project.isPromoted ?? false) || (showFeatured ?? false))
                    PositionedDirectional(
                      bottom: 0,
                      end: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.color.tertiaryColor,
                          borderRadius: const BorderRadiusDirectional.only(
                            topStart: Radius.circular(12),
                            bottomEnd: Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: Center(
                            child: CustomText(
                              UiUtils.translate(context, 'featured'),
                              fontWeight: FontWeight.w600,
                              color: context.color.buttonColor,
                              fontSize: context.font.small,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      UiUtils.imageType(
                        project.category?.image ?? '',
                        width: 18,
                        height: 18,
                        color: Constant.adaptThemeColorSvg
                            ? context.color.tertiaryColor
                            : null,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: CustomText(
                          project.category?.category ?? '',
                          fontWeight: FontWeight.w400,
                          fontSize: context.font.large,
                          color: context.color.textLightColor,
                        ),
                      ),
                      CustomText(
                        project.type!.translate(context),
                        maxLines: 1,
                        fontSize: context.font.small,
                        fontWeight: FontWeight.w600,
                        color: context.color.tertiaryColor,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomText(
                    project.title ?? '',
                    maxLines: 1,
                    fontSize: context.font.larger,
                    fontWeight: FontWeight.w800,
                    color: context.color.textColorDark,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  CustomText(
                    '${project.city}, ${project.state}, ${project.country}',
                    maxLines: 1,
                    fontSize: context.font.small,
                    fontWeight: FontWeight.w400,
                    color: context.color.textColorDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
