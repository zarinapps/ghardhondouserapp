import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/project_card_horizontal.dart';
import 'package:flutter/material.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return const ProjectListScreen();
      },
    );
  }

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    context.read<FetchMyProjectsListCubit>().fetchMyProjects();

    _scrollController.addListener(() {
      if (_scrollController.isEndReached()) {
        if (context.read<FetchMyProjectsListCubit>().hasMoreData()) {
          context.read<FetchMyProjectsListCubit>().fetchMore();
        }
      }
    });
    super.initState();
  }

  String statusText(String text) {
    if (text == '1') {
      return UiUtils.translate(context, 'active');
    } else if (text == '0') {
      return UiUtils.translate(context, 'inactive');
    } else if (text == 'rejected') {
      return UiUtils.translate(context, 'rejected');
    } else if (text == 'pending') {
      return UiUtils.translate(context, 'pending');
    }
    return '';
  }

  Color statusColor(String text) {
    if (text == '1') {
      return Colors.green;
    } else if (text == '0') {
      return Colors.orangeAccent;
    } else if (text == 'rejected') {
      return Colors.redAccent;
    } else if (text == 'pending') {
      return Colors.blue;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'myProjects'),
      ),
      body: RefreshIndicator(
        color: context.color.tertiaryColor,
        onRefresh: () async {
          await context.read<FetchMyProjectsListCubit>().fetchMyProjects();
        },
        child: BlocBuilder<FetchMyProjectsListCubit, FetchMyProjectsListState>(
          builder: (context, state) {
            if (state is FetchMyProjectsListInProgress) {
              return buildProjectShimmer();
            }
            if (state is FetchMyProjectsListFail) {
              if (state.error is NoInternetConnectionError) {
                return NoInternet(
                  onRetry: () {
                    context.read<FetchMyProjectsListCubit>().fetchMyProjects();
                  },
                );
              }
              return const SomethingWentWrong();
            }
            if (state is FetchMyProjectsListSuccess) {
              if (state.projects.isEmpty) {
                return const NoDataFound();
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: Constant.scrollPhysics,
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: state.projects.length,
                      padding: const EdgeInsets.all(14),
                      itemBuilder: (context, index) {
                        final project = state.projects[index];
                        final requestStatus =
                            project.requestStatus == 'approved'
                                ? project.status.toString()
                                : project.requestStatus.toString();
                        return ProjectHorizontalCard(
                          project: project,
                          statusButton: StatusButton(
                            lable: statusText(requestStatus),
                            color: statusColor(requestStatus)
                                .withValues(alpha: 0.2),
                            textColor: statusColor(requestStatus),
                          ),
                        );
                      },
                    ),
                  ),
                  if (context
                      .watch<FetchMyProjectsListCubit>()
                      .hasMoreData()) ...[
                    Center(child: UiUtils.progress()),
                  ],
                ],
              );
              // return ProjectCard(title: "Hello",categoryIcon: ,);
            }
            if (state is FetchMyProjectsListFail) {
              return Center(
                child: CustomText(state.error.toString()),
              );
            }

            return Container();
          },
        ),
      ),
    );
  }

  Widget buildProjectShimmer() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        vertical: 26,
        horizontal: 16,
      ),
      itemCount: 15,
      separatorBuilder: (context, index) {
        return const SizedBox(
          height: 12,
        );
      },
      itemBuilder: (context, index) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: CustomShimmer(height: 90, width: 90),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    CustomShimmer(
                      height: 10,
                      width: context.screenWidth - 50,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const CustomShimmer(
                      height: 10,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomShimmer(
                      height: 10,
                      width: context.screenWidth / 1.2,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomShimmer(
                      height: 10,
                      width: context.screenWidth / 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
