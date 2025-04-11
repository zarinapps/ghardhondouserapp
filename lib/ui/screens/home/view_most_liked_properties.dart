import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class MostLikedPropertiesScreen extends StatefulWidget {
  const MostLikedPropertiesScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (context) {
        return const MostLikedPropertiesScreen();
      },
    );
  }

  @override
  State<MostLikedPropertiesScreen> createState() =>
      _MostLikedPropertiesScreenState();
}

class _MostLikedPropertiesScreenState extends State<MostLikedPropertiesScreen> {
  ///This Scroll controller for listen page end
  final ScrollController _pageScollController = ScrollController();
  @override
  void initState() {
    context.read<FetchMostLikedPropertiesCubit>().fetch();
    _pageScollController.addListener(onPageEnd);
    super.initState();
  }

  ///This method will listen page scroll changes
  void onPageEnd() {
    ///This is exetension which will check if we reached end or not
    if (_pageScollController.isEndReached()) {
      if (context.read<FetchMostLikedPropertiesCubit>().hasMoreData()) {
        context.read<FetchMostLikedPropertiesCubit>().fetchMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'mostLiked'),
      ),
      body: BlocBuilder<FetchMostLikedPropertiesCubit,
          FetchMostLikedPropertiesState>(
        builder: (context, state) {
          if (state is FetchMostLikedPropertiesInProgress) {
            return Center(
              child: UiUtils.progress(
                normalProgressColor: context.color.tertiaryColor,
              ),
            );
          }
          if (state is FetchMostLikedPropertiesFailure) {
            return const SomethingWentWrong();
          }
          if (state is FetchMostLikedPropertiesSuccess) {
            if (state.properties.isEmpty) {
              return Center(
                child: NoDataFound(
                  onTap: () {
                    context.read<FetchMostLikedPropertiesCubit>().fetch();
                  },
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    controller: _pageScollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.properties.length,
                    itemBuilder: (context, index) {
                      final property = state.properties[index];
                      return GestureDetector(
                        onTap: () {
                          HelperUtils.goToNextPage(
                            Routes.propertyDetails,
                            context,
                            false,
                            args: {
                              'propertyData': property,
                              'fromMyProperty': false,
                            },
                          );
                        },
                        child: PropertyHorizontalCard(
                          property: property,
                        ),
                      );
                    },
                  ),
                ),
                if (state.isLoadingMore) UiUtils.progress(),
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
