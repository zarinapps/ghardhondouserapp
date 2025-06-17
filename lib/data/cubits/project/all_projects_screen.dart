import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/project_card_horizontal.dart';
import 'package:flutter/material.dart';

class AllProjectsScreen extends StatefulWidget {
  const AllProjectsScreen({required this.isPromoted, super.key, this.title});
  final bool isPromoted;
  final String? title;
  static Route<dynamic> route(RouteSettings settings) {
    final args = settings.arguments as Map?;
    final isPromoted = args?['isPromoted'] as bool;
    final title = args?['title'] as String? ?? '';
    return CupertinoPageRoute(
      builder: (context) {
        return AllProjectsScreen(
          isPromoted: isPromoted,
          title: title,
        );
      },
    );
  }

  @override
  State<AllProjectsScreen> createState() => _AllProjectsScreenState();
}

class _AllProjectsScreenState extends State<AllProjectsScreen> {
  final ScrollController _controller = ScrollController();
  @override
  void initState() {
    fetchProjects();
    addPageScrollListener();
    super.initState();
  }

  Future<void> fetchProjects() async {
    if (widget.isPromoted) {
      await context.read<FetchMyProjectsListCubit>().fetchPromotedProjects();
    } else {
      await context.read<FetchMyProjectsListCubit>().fetch();
    }
  }

  void addPageScrollListener() {
    _controller.addListener(pageScrollListener);
  }

  void pageScrollListener() {
    ///This will load data on page end
    if (_controller.isEndReached()) {
      if (mounted) {
        if (context.read<FetchMyProjectsListCubit>().hasMoreData()) {
          context
              .read<FetchMyProjectsListCubit>()
              .fetchMore(isPromoted: widget.isPromoted);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle = widget.title != ''
        ? widget.title
        : widget.isPromoted
            ? UiUtils.translate(context, 'featuredProjects')
            : UiUtils.translate(context, 'projects');
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: appBarTitle,
      ),
      body: SingleChildScrollView(
        controller: _controller,
        physics: Constant.scrollPhysics,
        child: BlocBuilder<FetchMyProjectsListCubit, FetchMyProjectsListState>(
          builder: (context, state) {
            if (state is FetchMyProjectsListInProgress) {
              return UiUtils.buildHorizontalShimmer();
            }
            if (state is FetchMyProjectsListSuccess) {
              return Container(
                margin: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.projects.length,
                      itemBuilder: (context, index) {
                        final project = state.projects[index];
                        return ProjectHorizontalCard(
                          project: project,
                          isRejected: false,
                        );
                      },
                    ),
                    if (context
                        .watch<FetchMyProjectsListCubit>()
                        .hasMoreData()) ...[
                      Center(child: UiUtils.progress()),
                    ],
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
