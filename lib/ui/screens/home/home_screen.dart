// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:ebroker/data/cubits/home_page_data_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_city_property_list.dart';
import 'package:ebroker/data/cubits/property/home_infinityscroll_cubit.dart';
import 'package:ebroker/data/helper/design_configs.dart';
import 'package:ebroker/data/model/agent/agent_model.dart';
import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/model/home_slider.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/agents_card.dart';
import 'package:ebroker/ui/screens/home/Widgets/property_card_big.dart';
import 'package:ebroker/ui/screens/home/Widgets/property_gradient_card.dart';
import 'package:ebroker/ui/screens/home/city_properties_screen.dart';
import 'package:ebroker/ui/screens/home/widgets/category_card.dart';
import 'package:ebroker/ui/screens/home/widgets/custom_grid.dart';
import 'package:ebroker/ui/screens/home/widgets/header_card.dart';
import 'package:ebroker/ui/screens/home/widgets/homeListener.dart';
import 'package:ebroker/ui/screens/home/widgets/home_search.dart';
import 'package:ebroker/ui/screens/home/widgets/home_shimmers.dart';
import 'package:ebroker/ui/screens/home/widgets/location_widget.dart';
import 'package:ebroker/ui/screens/project/view/project_card_big.dart';
import 'package:ebroker/ui/screens/proprties/viewAll.dart';
import 'package:ebroker/utils/admob/bannerAdLoadWidget.dart';
import 'package:ebroker/utils/network/networkAvailability.dart';
import 'package:ebroker/utils/sliver_grid_delegate_with_fixed_cross_axis_count_and_fixed_height.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
// JWT Token

const double sidePadding = 18;

class HomeScreen extends StatefulWidget {
  final String? from;

  const HomeScreen({super.key, this.from});

  @override
  HomeScreenState createState() => HomeScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    return BlurredRouter(
      builder: (_) => HomeScreen(from: arguments['from'] as String),
    );
  }
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;
  HomePageStateListener homeStateListener = HomePageStateListener();

  @override
  void initState() {
    context.read<HomePageInfinityScrollCubit>().fetch();
    context.read<FetchHomePageDataCubit>().fetch(
          forceRefresh: false,
        );
    initializeSettings();
    addPageScrollListener();
    initializeHomeStateListener();
    super.initState();
  }

  void initializeSettings() {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment(
      'force-disable-demo-mode',
    )) {
      Constant.isDemoModeOn =
          settingsCubit.getSetting(SystemSetting.demoMode) as bool? ?? false;
    }
  }

  void addPageScrollListener() {
    homeScreenController.addListener(pageScrollListener);
  }

  void initializeHomeStateListener() {
    homeStateListener.init(
      onNetAvailable: () {
        if (mounted) {
          loadInitialData(
            loadWithoutDelay: true,
            context,
          );
          setState(() {});
        }
      },
    );
  }

  void pageScrollListener() {
    ///This will load data on page end
    if (homeScreenController.isEndReached()) {
      if (mounted) {
        if (context.read<HomePageInfinityScrollCubit>().hasMoreData()) {
          context.read<HomePageInfinityScrollCubit>().fetchMore();
        }
      }
    }
  }

  void _onTapPromotedSeeAll() {
    Navigator.pushNamed(context, Routes.promotedPropertiesScreen);
  }

  void _onTapNearByPropertiesAll() {
    final stateMap = StateMap<
        FetchNearbyPropertiesInitial,
        FetchNearbyPropertiesInProgress,
        FetchNearbyPropertiesSuccess,
        FetchNearbyPropertiesFailure>();

    ViewAllScreen<FetchNearbyPropertiesCubit, FetchNearbyPropertiesState>(
      title: 'nearByProperties'.translate(context),
      map: stateMap,
    ).open(context);
  }

  void _onTapMostLikedAll() {
    Navigator.pushNamed(context, Routes.mostLikedPropertiesScreen);
  }

  void _onTapMostViewedSeeAll() {
    Navigator.pushNamed(context, Routes.mostViewedPropertiesScreen);
  }

  void _onRefresh() {
    context.read<FetchNearbyPropertiesCubit>().fetch(
          forceRefresh: true,
        );
    context.read<FetchCityCategoryCubit>().fetchCityCategory(
          forceRefresh: true,
        );
    context.read<FetchPersonalizedPropertyList>().fetch(
          forceRefresh: true,
        );
    context.read<FetchHomePageDataCubit>().fetch(
          forceRefresh: true,
        );
    context.read<HomePageInfinityScrollCubit>().fetch();
    if (GuestChecker.value == false) {
      context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymous: false,
            forceRefresh: true,
          );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final homeScreenState = homeStateListener.listen(context);
    HiveUtils.getJWT()?.log('JWT');

    ///
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: UiUtils.getSystemUiOverlayStyle(context: context),
        elevation: 0,
        leadingWidth: (HiveUtils.getCityName() != null &&
                HiveUtils.getCityName().toString().isNotEmpty)
            ? 200.rw(context)
            : 130,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(
            start: sidePadding.rw(context),
          ),
          child: (HiveUtils.getCityName() != null &&
                  HiveUtils.getCityName().toString().isNotEmpty)
              ? const LocationWidget() as Widget? ?? const SizedBox.shrink()
              : LoadAppSettings().loadHomeLogo(appSettings.appHomeScreen!)
                      as Widget? ??
                  const SizedBox.shrink(),
        ),
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      ),
      backgroundColor: context.color.primaryColor,
      body: RefreshIndicator(
        color: context.color.tertiaryColor,
        onRefresh: () async {
          await CheckInternet.check(
            onInternet: () {
              _onRefresh();
            },
            onNoInternet: () {
              HelperUtils.showSnackBarMessage(
                context,
                'noInternet'.translate(context),
              );
            },
          );
        },
        child: Builder(
          builder: (context) {
            // if (homeScreenState.state == HomeScreenDataState.fail) {
            //   return SingleChildScrollView(
            //     physics: Constant.scrollPhysics,
            //     child: Container(
            //       alignment: Alignment.topCenter,
            //       height: context.screenHeight - 235,
            //       child: const SomethingWentWrong(),
            //     ),
            //   );
            // }
            return BlocBuilder<FetchSystemSettingsCubit,
                FetchSystemSettingsState>(
              builder: (context, state) {
                // if (homeScreenState.state == HomeScreenDataState.nointernet) {
                //   return NoInternet(
                //     onRetry: () {
                //       CheckInternet.check(
                //         onInternet: () {
                //           _onRefresh();
                //           Navigator.popUntil(context, (route) => route.isFirst);
                //         },
                //         onNoInternet: () {
                //           HelperUtils.showSnackBarMessage(
                //             context,
                //             'noInternet'.translate(context),
                //           );
                //         },
                //       );
                //     },
                //   );
                // }
                return BlocBuilder<FetchHomePageDataCubit,
                    FetchHomePageDataState>(
                  builder: (homeContext, homeState) {
                    if (homeState is FetchHomePageDataLoading) {
                      return const HomeShimmer();
                    }
                    if (homeState is FetchHomePageDataSuccess) {
                      final home = homeState.homePageDataModel;
                      return SingleChildScrollView(
                        controller: homeScreenController,
                        physics: Constant.scrollPhysics,
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).padding.top,
                        ),
                        child: BlocProvider(
                          create: (context) => FetchHomePageDataCubit(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              ...AppSettings.sections.map((section) {
                                switch (section) {
                                  case HomeScreenSections.search:
                                    return const HomeSearchField();
                                  case HomeScreenSections.personalizedFeed:
                                    return const PersonalizedPropertyWidget();
                                  case HomeScreenSections.slider:
                                    return sliderWidget(home.sliderSection);
                                  case HomeScreenSections.category:
                                    return categoryWidget(
                                      home.categoriesSection,
                                    );
                                  case HomeScreenSections.nearbyProperties:
                                    return buildNearByProperties(
                                      nearByProperties: home.nearByProperties,
                                    );
                                  case HomeScreenSections.featuredProperties:
                                    return featuredProperties(
                                      home.featuredSection,
                                      context,
                                    );
                                  case HomeScreenSections.agents:
                                    return buildAgents(home.agentsList);
                                  case HomeScreenSections.mostLikedProperties:
                                    return mostLikedProperties(
                                      home.mostLikedProperties,
                                      context,
                                    );
                                  case HomeScreenSections.mostViewed:
                                    return mostViewedProperties(
                                      home.mostViewedProperties,
                                      context,
                                    );
                                  case HomeScreenSections.popularCities:
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          const BannerAdWidget(),
                                          popularCityProperties(),
                                        ],
                                      ),
                                    );
                                  case HomeScreenSections.project:
                                    return buildProjects(home.projectSection);
                                  case HomeScreenSections.featuredProjects:
                                    return buildFeaturedProjects(
                                      home.featuredProjectSection,
                                    );
                                }
                              }),
                              allProperties(context: context),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget allProperties({required BuildContext context}) {
    return BlocBuilder<HomePageInfinityScrollCubit,
        HomePageInfinityScrollState>(
      builder: (context, state) {
        if (state is HomePageInfinityScrollFailure) {
          const SizedBox.shrink();
        }
        if (state is HomePageInfinityScrollInProgress) {
          return LayoutBuilder(
            builder: (context, c) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                          child: CustomShimmer(
                            height: 90,
                            width: 90,
                          ),
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
                                width: c.maxWidth - 100,
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
                                width: c.maxWidth / 1.2,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              CustomShimmer(
                                height: 10,
                                width: c.maxWidth / 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                shrinkWrap: true,
                itemCount: 6,
              );
            },
          );
        }

        if (state is HomePageInfinityScrollSuccess) {
          return Builder(
            builder: (context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TitleHeader(
                    enableShowAll: false,
                    title: UiUtils.translate(
                      context,
                      'allProperties',
                    ),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    itemCount: state.properties.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return PropertyHorizontalCard(
                        property: state.properties[index],
                      );
                    },
                  ),
                  if (context
                      .watch<HomePageInfinityScrollCubit>()
                      .isLoadingMore()) ...[
                    Center(child: UiUtils.progress()),
                  ],
                ],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  bool cityEmpty() {
    if (context.watch<FetchCityCategoryCubit>().state
        is FetchCityCategorySuccess) {
      return (context.watch<FetchCityCategoryCubit>().state
              as FetchCityCategorySuccess)
          .cities
          .isEmpty;
    }
    return true;
  }

  Widget buildProjects(List<ProjectModel> projectSection) {
    return Column(
      children: [
        if (projectSection.isNotEmpty) ...[
          TitleHeader(
            title: 'Project section'.translate(context),
            onSeeAll: () {
              Navigator.pushNamed(context, Routes.allProjectsScreen);
            },
          ),
          Container(
            height: 250,
            alignment: AlignmentDirectional.centerStart,
            margin: const EdgeInsets.only(bottom: 8, right: 7),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: projectSection.length,
              physics: Constant.scrollPhysics,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final project = projectSection[index];
                return Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: 10,
                  ),
                  child: ProjectCardBig(
                    project: project,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget buildFeaturedProjects(List<ProjectModel> projectSection) {
    return Column(
      children: [
        if (projectSection.isNotEmpty) ...[
          TitleHeader(
            title: 'featuredProjects'.translate(context),
            onSeeAll: () {
              Navigator.pushNamed(context, Routes.allProjectsScreen);
            },
          ),
          Container(
            alignment: AlignmentDirectional.centerStart,
            height: 250,
            margin: const EdgeInsets.only(bottom: 8, right: 7),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: projectSection.length,
              physics: Constant.scrollPhysics,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final project = projectSection[index];
                return GestureDetector(
                  onTap: () async {
                    GuestChecker.check(
                      onNotGuest: () async {
                        final checkPackage = CheckPackage();

                        final packageAvailable =
                            await checkPackage.checkPackageAvailable(
                          packageType: PackageType.projectAccess,
                        );
                        if (packageAvailable &&
                            project.addedBy.toString() !=
                                HiveUtils.getUserId()) {
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
                            log('Error is $e');
                            Widgets.hideLoder(context);
                          }
                        } else if (project.addedBy.toString() ==
                            HiveUtils.getUserId()) {
                          try {
                            unawaited(Widgets.showLoader(context));
                            final projectRepository = ProjectRepository();
                            final projectDetails =
                                await projectRepository.getProjectDetails(
                              id: project.id!,
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
                            log('Error is $e');
                            Widgets.hideLoder(context);
                          }
                        } else {
                          Widgets.hideLoder(context);
                          await UiUtils.showBlurredDialoge(
                            context,
                            dialoge: BlurredDialogBox(
                              title: 'Subscription needed',
                              isAcceptContainesPush: true,
                              onAccept: () async {
                                await Navigator.popAndPushNamed(
                                  context,
                                  Routes.subscriptionPackageListRoute,
                                  arguments: {'from': 'home'},
                                );
                              },
                              content: CustomText(
                                'subscribeToUseThisFeature'.translate(context),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: 10,
                    ),
                    child: ProjectCardBig(
                      project: project,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget buildAgents(List<AgentModel> agents) {
    if (agents.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleHeader(
            title: UiUtils.translate(context, 'agents'),
            onSeeAll: () {
              Navigator.pushNamed(context, Routes.agentListScreen);
            },
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              itemCount: agents.length < 5 ? agents.length : 5,
              physics: Constant.scrollPhysics,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final agent = agents[index];
                return GestureDetector(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: 8,
                    ),
                    child: AgentCard(
                      agent: agent,
                      propertyCount: agent.propertyCount,
                      name: agent.name,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget popularCityProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!cityEmpty())
          TitleHeader(
            title: 'popularCities'.translate(context),
            onSeeAll: () {
              Navigator.pushNamed(context, Routes.cityListScreen);
            },
          ),
        BlocBuilder<FetchCityCategoryCubit, FetchCityCategoryState>(
          builder: (context, FetchCityCategoryState state) {
            if (state is FetchCityCategorySuccess) {
              final cities = state.cities.take(10).toList();
              return CustomImageGrid(
                images: cities.map((e) => e.image).toList(),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  Widget mostViewedProperties(
    List<PropertyModel> mostViewedProperties,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostViewedProperties.isNotEmpty)
          TitleHeader(
            onSeeAll: _onTapMostViewedSeeAll,
            title: UiUtils.translate(context, 'mostViewed'),
          ),
        buildMostViewedProperties(mostViewedProperties),
      ],
    );
  }

  Widget mostLikedProperties(
    List<PropertyModel> mostLikedProperties,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostLikedProperties.isNotEmpty) ...[
          TitleHeader(
            onSeeAll: _onTapMostLikedAll,
            title: UiUtils.translate(
              context,
              'mostLikedProperties',
            ),
          ),
          buildMostLikedProperties(mostLikedProperties),
          const SizedBox(
            height: 15,
          ),
        ],
      ],
    );
  }

  Widget featuredProperties(
    List<PropertyModel> featuredProperties,
    BuildContext context,
  ) {
    if (featuredProperties.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleHeader(
            onSeeAll: _onTapPromotedSeeAll,
            title: UiUtils.translate(
              context,
              'promotedProperties',
            ),
          ),
          buildPromotedProperties(featuredProperties),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget sliderWidget(List<HomeSlider> sliderList) {
    if (sliderList.isNotEmpty) {
      return const SliderWidget();
    }
    return const SizedBox.shrink();
  }

  Widget buildCityCard(FetchCityCategorySuccess state, int index) {
    if (index >= state.cities.length) {
      return const SizedBox.shrink();
    }
    final city = state.cities[index];
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GestureDetector(
        onTap: () {
          context.read<FetchCityPropertyList>().fetch(
                cityName: city.name,
                forceRefresh: true,
              );
          Navigator.push(
            context,
            BlurredRouter(
              builder: (context) {
                return CityPropertiesScreen(
                  cityName: city.name,
                );
              },
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            UiUtils.getImage(
              city.image,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.68),
                    Colors.black.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 8,
              start: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    city.name.firstUpperCase(),
                    color: context.color.buttonColor,
                    fontSize: context.font.normal,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  CustomText(
                    '${city.count} ${'properties'.translate(context)}',
                    color: context.color.buttonColor,
                    fontSize: context.font.small,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPromotedProperties(List<PropertyModel> promotedProperties) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        itemCount: promotedProperties.length.clamp(0, 6),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(
          horizontal: sidePadding,
        ),
        physics: Constant.scrollPhysics,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return BlocProvider(
            create: (context) {
              return AddToFavoriteCubitCubit();
            },
            child: PropertyCardBig(
              key: UniqueKey(),
              isFirst: index == 0,
              property: promotedProperties[index],
              onLikeChange: (type) {
                if (type == FavoriteType.add) {
                  context
                      .read<FetchFavoritesCubit>()
                      .add(promotedProperties[index]);
                } else {
                  context
                      .read<FetchFavoritesCubit>()
                      .remove(promotedProperties[index].id);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget buildMostLikedProperties(List<PropertyModel> mostLiked) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: sidePadding,
      ),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        mainAxisSpacing: 8,
        crossAxisCount: 2,
        height: 275,
        crossAxisSpacing: 6,
      ),
      itemCount: mostLiked.length.clamp(0, 4),
      itemBuilder: (context, index) {
        final properties = mostLiked[index];
        return BlocProvider(
          create: (context) => AddToFavoriteCubitCubit(),
          child: PropertyCardBig(
            showEndPadding: false,
            isFirst: index == 0,
            onLikeChange: (type) {
              if (type == FavoriteType.add) {
                context.read<FetchFavoritesCubit>().add(properties);
              } else {
                context.read<FetchFavoritesCubit>().remove(properties.id);
              }
            },
            property: properties,
          ),
        );
      },
    );
  }

  Widget buildNearByProperties({
    required List<PropertyModel> nearByProperties,
  }) {
    if (nearByProperties.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleHeader(
          onSeeAll: _onTapNearByPropertiesAll,
          title: "${UiUtils.translate(
            context,
            "nearByProperties",
          )} (${HiveUtils.getCityName()})",
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            physics: Constant.scrollPhysics,
            itemCount: nearByProperties.length.clamp(0, 6),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              var model = nearByProperties[index];
              model = context.watch<PropertyEditCubit>().get(model);
              return PropertyGradiendCard(
                model: model,
                isFirst: index == 0,
                showEndPadding: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildMostViewedProperties(List<PropertyModel> mostViewed) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: sidePadding,
      ),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        mainAxisSpacing: 8,
        crossAxisCount: 2,
        height: 275,
        crossAxisSpacing: 6,
      ),
      itemCount: mostViewed.length.clamp(0, 4),
      itemBuilder: (context, index) {
        final property = mostViewed[index];
        return BlocProvider(
          create: (context) => AddToFavoriteCubitCubit(),
          child: PropertyCardBig(
            showEndPadding: false,
            isFirst: index == 0,
            onLikeChange: (type) {
              if (type == FavoriteType.add) {
                context.read<FetchFavoritesCubit>().add(property);
              } else {
                context.read<FetchFavoritesCubit>().remove(property.id);
              }
            },
            property: property,
          ),
        );
      },
    );
  }

  Widget categoryWidget(List<Category> categories) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          height: 44.rh(context),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            physics: Constant.scrollPhysics,
            scrollDirection: Axis.horizontal,
            itemCount: categories.length.clamp(0, Constant.maxCategoryLength),
            itemBuilder: (context, index) {
              final category = categories[index];
              Constant.propertyFilter = null;
              if (index == (Constant.maxCategoryLength - 1)) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(start: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, Routes.categories);
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        minWidth: 100.rw(context),
                      ),
                      height: 44.rh(context),
                      alignment: Alignment.center,
                      decoration: DesignConfig.boxDecorationBorder(
                        color: context.color.secondaryColor,
                        radius: 10,
                        borderWidth: 1.5,
                        borderColor: context.color.borderColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CustomText(UiUtils.translate(context, 'more')),
                      ),
                    ),
                  ),
                );
              }
              return buildCategoryCard(
                context: context,
                category: category,
                frontSpacing: index != 0,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildCategoryCard({
    required BuildContext context,
    required Category category,
    bool? frontSpacing,
  }) {
    return CategoryCard(
      frontSpacing: frontSpacing ?? false,
      onTapCategory: (category) {
        currentVisitingCategoryId = category.id;
        currentVisitingCategory = category;
        Navigator.of(context).pushNamed(
          Routes.propertiesList,
          arguments: {'catID': category.id, 'catName': category.category},
        );
      },
      category: category,
    );
  }
}

class PersonalizedPropertyWidget extends StatelessWidget {
  const PersonalizedPropertyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchPersonalizedPropertyList,
        FetchPersonalizedPropertyListState>(
      builder: (context, state) {
        if (state is FetchPersonalizedPropertyInProgress) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleHeader(
                onSeeAll: () {},
                title: 'personalizedFeed'.translate(context),
              ),
              const PromotedPropertiesShimmer(),
            ],
          );
        }

        if (state is FetchPersonalizedPropertySuccess) {
          if (state.properties.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleHeader(
                onSeeAll: () {
                  final stateMap = StateMap<
                      FetchPersonalizedPropertyInitial,
                      FetchPersonalizedPropertyInProgress,
                      FetchPersonalizedPropertySuccess,
                      FetchPersonalizedPropertyFail>();

                  ViewAllScreen<FetchPersonalizedPropertyList,
                      FetchPersonalizedPropertyListState>(
                    title: 'personalizedFeed'.translate(context),
                    map: stateMap,
                  ).open(context);
                },
                title: 'personalizedFeed'.translate(context),
              ),
              SizedBox(
                height: 261,
                child: ListView.builder(
                  itemCount: state.properties.length.clamp(0, 6),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: sidePadding,
                  ),
                  physics: Constant.scrollPhysics,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    var propertymodel = state.properties[index];
                    propertymodel =
                        context.watch<PropertyEditCubit>().get(propertymodel);
                    return BlocProvider(
                      create: (context) {
                        return AddToFavoriteCubitCubit();
                      },
                      child: PropertyCardBig(
                        key: UniqueKey(),
                        isFirst: index == 0,
                        property: propertymodel,
                        onLikeChange: (type) {
                          if (type == FavoriteType.add) {
                            context
                                .read<FetchFavoritesCubit>()
                                .add(propertymodel);
                          } else {
                            context
                                .read<FetchFavoritesCubit>()
                                .remove(state.properties[index].id);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        return Container();
      },
    );
  }
}

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<int> _bannerIndex = ValueNotifier(0);
  int bannersLength = 0;
  late Timer _timer;
  final PageController _pageController = PageController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    context.read<FetchHomePageDataCubit>().fetch(
          forceRefresh: false,
        );
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_bannerIndex.value < bannersLength - 1) {
        _bannerIndex.value++;
      } else {
        _bannerIndex.value = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _bannerIndex.value,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _bannerIndex.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<FetchHomePageDataCubit, FetchHomePageDataState>(
      builder: (context, state) {
        if (state is FetchHomePageDataLoading) {
          return Column(
            children: [
              SizedBox(
                height: 15.rh(context),
              ),
              Container(
                margin: const EdgeInsets.only(
                  right: 18,
                  top: 10,
                  left: 18,
                  bottom: 10,
                ),
                height: 170.rh(context),
                child: ListView.builder(
                  controller: _pageController,
                  clipBehavior: Clip.antiAlias,
                  scrollDirection: Axis.horizontal,
                  physics: Constant.scrollPhysics,
                  itemCount: 1,
                  itemBuilder: (context, index) => CustomShimmer(
                    height: 130.rh(context),
                    width: context.screenWidth * 0.9,
                  ),
                ),
              ),
              SizedBox(
                height: 15.rh(context),
              ),
            ],
          );
        }
        if (state is FetchHomePageDataSuccess &&
            state.homePageDataModel.sliderSection.isNotEmpty) {
          final banners = state.homePageDataModel.sliderSection;
          bannersLength = state.homePageDataModel.sliderSection.length;
          return Column(
            children: <Widget>[
              SizedBox(
                height: 15.rh(context),
              ),
              CarouselSlider(
                items: banners.map((e) {
                  return Builder(
                    builder: (context) {
                      return _buildBanner(e);
                    },
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 170.rh(context),
                  viewportFraction: 1,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  enlargeCenterPage: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _bannerIndex.value = index;
                    });
                  },
                ),
              ),
              // SizedBox(
              //   height: 170.rh(context),
              //   child: PageView.builder(
              //     controller: _pageController,
              //     clipBehavior: Clip.antiAlias,
              //     itemCount: state.homePageDataModel.sliderSection.length,
              //     onPageChanged: (index) {
              //       _bannerIndex.value = index;
              //     },
              //     itemBuilder: (context, index) => _buildBanner(
              //       state.homePageDataModel.sliderSection[index],
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: 10,
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBanner(HomeSlider banner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: sidePadding),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          if (banner.sliderType == '1') {
            UiUtils.showFullScreenImage(
              context,
              provider: NetworkImage(banner.image.toString()),
            );
          } else if (banner.sliderType == '2') {
            await Navigator.pushNamed(
              context,
              Routes.propertiesList,
              arguments: {
                'catID': banner.categoryId,
                'catName': banner.category!.category,
              },
            );
          } else if (banner.sliderType == '3') {
            try {
              unawaited(Widgets.showLoader(context));
              final fetch = PropertyRepository();
              final dataOutput = await fetch.fetchPropertyFromPropertyId(
                id: int.parse(banner.propertysId!),
                isMyProperty: banner.property!.addedBy.toString() ==
                    HiveUtils.getUserId(),
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
                      'propertiesList': dataOutput,
                      'fromMyProperty': false,
                    },
                  );
                },
              );
            } catch (e) {
              log('Error is $e');
              Widgets.hideLoder(context);
            }
          } else if (banner.sliderType == '4') {
            await url_launcher.launchUrl(Uri.parse(banner.link!));
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: UiUtils.getImage(
            banner.image.toString(),
            height: context.screenHeight * 0.3,
            width: context.screenWidth,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
