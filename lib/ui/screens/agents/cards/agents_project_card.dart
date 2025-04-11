import 'package:ebroker/data/cubits/agents/fetch_projects_cubit.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/project_data.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class AgentProjects extends StatefulWidget {
  const AgentProjects({
    required this.agentId,
    required this.isAdmin,
    super.key,
  });
  final bool isAdmin;
  final int agentId;

  @override
  State<AgentProjects> createState() => _AgentProjectsState();
}

class _AgentProjectsState extends State<AgentProjects> {
  ///This Scroll controller for listen page end
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    _pageScrollController.addListener(onPageEnd);

    super.initState();
  }

  ///This method will listen page scroll changes
  void onPageEnd() {
    ///This is exetension which will check if we reached end or not
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchAgentsProjectCubit>().hasMoreData()) {
        context.read<FetchAgentsProjectCubit>().fetchMore(
              isAdmin: widget.isAdmin,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<FetchAgentsProjectCubit, FetchAgentsProjectState>(
        builder: (context, state) {
          if (state is FetchAgentsProjectLoading) {
            return Center(
              child: UiUtils.progress(
                normalProgressColor: context.color.tertiaryColor,
              ),
            );
          }
          if (state is FetchAgentsProjectFailure) {
            return const SomethingWentWrong();
          }
          if (state is FetchAgentsProjectSuccess &&
              state.agentsProperty.projectData.isEmpty) {
            return Container(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(
                top: 15,
                left: 18,
                right: 18,
                bottom: 8,
              ),
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                border: Border.all(
                  color: context.color.borderColor,
                  width: 1.5,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: NoDataFound(
                onTap: () {
                  context.read<FetchAgentsProjectCubit>().fetchAgentsProject(
                        agentId: widget.agentId,
                        forceRefresh: true,
                        isAdmin: widget.isAdmin,
                      );
                },
              ),
            );
          }
          if (state is FetchAgentsProjectSuccess) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.only(
                      top: 15,
                      left: 18,
                      right: 18,
                    ),
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 18,
                      right: 18,
                    ),
                    decoration: BoxDecoration(
                      color: context.color.secondaryColor,
                      border: Border.all(
                        color: context.color.borderColor,
                        width: 1.5,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 12,
                          ),
                          height: 36,
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: context.color.secondaryColor,
                            border: Border.all(
                              color: context.color.borderColor,
                              width: 1.5,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                          ),
                          child: CustomText(
                            fontSize: 16,
                            color: context.color.inverseSurface,
                            fontWeight: FontWeight.w700,
                            '${state.agentsProperty.customerData.projectCount} ${UiUtils.translate(context, 'projects')}',
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            physics: Constant.scrollPhysics,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            controller: _pageScrollController,
                            itemCount: state.agentsProperty.projectData.length,
                            itemBuilder: (context, index) {
                              final agentsProject =
                                  state.agentsProperty.projectData[index];
                              return AgentProjectCardBig(
                                project: agentsProject,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (context
                    .watch<FetchAgentsProjectCubit>()
                    .isLoadingMore()) ...[
                  Center(child: UiUtils.progress()),
                ],
                const SizedBox(
                  height: 30,
                ),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}

class AgentProjectCardBig extends StatelessWidget {
  const AgentProjectCardBig({
    required this.project,
    this.color,
    super.key,
  });
  final ProjectData project;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          GuestChecker.check(
            onNotGuest: () async {
              unawaited(Widgets.showLoader(context));

              if (project.addedBy == HiveUtils.getUserId()) {
                try {
                  unawaited(Widgets.showLoader(context));
                  final projectRepository = ProjectRepository();
                  final projectDetails = await projectRepository
                      .getProjectDetails(id: project.id, isMyProject: true);
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
              } else if (project.addedBy != HiveUtils.getUserId()) {
                final checkPackage = CheckPackage();

                final packageAvailable =
                    await checkPackage.checkPackageAvailable(
                  packageType: PackageType.projectAccess,
                );
                if (packageAvailable) {
                  try {
                    unawaited(Widgets.showLoader(context));
                    final projectRepository = ProjectRepository();
                    final projectDetails = await projectRepository
                        .getProjectDetails(id: project.id, isMyProject: false);
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
        margin: const EdgeInsets.symmetric(vertical: 8),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: UiUtils.getImage(
                      project.image,
                      height: MediaQuery.of(context).size.height * 0.18,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fill,
                      blurHash: project.image,
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
                  if (project.isFeatured)
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
                        project.category.image,
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
                          project.category.category,
                          fontWeight: FontWeight.w400,
                          fontSize: context.font.large,
                          color: context.color.textLightColor,
                        ),
                      ),
                      CustomText(
                        project.type.firstUpperCase(),
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
                    project.title,
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
