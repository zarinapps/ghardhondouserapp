// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:ebroker/data/cubits/fetch_home_page_data_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_city_property_list.dart';
import 'package:ebroker/data/cubits/property/fetch_premium_properties_cubit.dart';
import 'package:ebroker/data/cubits/property/home_infinityscroll_cubit.dart';
import 'package:ebroker/data/model/agent/agent_model.dart';
import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/model/city_model.dart';
import 'package:ebroker/data/model/home_page_data_model.dart';
import 'package:ebroker/data/model/home_slider.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/agents_card.dart';
import 'package:ebroker/ui/screens/home/Widgets/property_card_big.dart';
import 'package:ebroker/ui/screens/home/Widgets/property_gradient_card.dart';
import 'package:ebroker/ui/screens/home/city_properties_screen.dart';
import 'package:ebroker/ui/screens/home/widgets/category_card.dart';
import 'package:ebroker/ui/screens/home/widgets/custom_grid.dart';
import 'package:ebroker/ui/screens/home/widgets/custom_refresh_indicator.dart';
import 'package:ebroker/ui/screens/home/widgets/header_card.dart';
import 'package:ebroker/ui/screens/home/widgets/home_search.dart';
import 'package:ebroker/ui/screens/home/widgets/home_shimmers.dart';
import 'package:ebroker/ui/screens/home/widgets/location_widget.dart';
import 'package:ebroker/ui/screens/project/view/project_card_big.dart';
import 'package:ebroker/ui/screens/proprties/view_all.dart';
import 'package:ebroker/utils/admob/banner_ad_load_widget.dart';
import 'package:ebroker/utils/extensions/lib/iterable.dart';
import 'package:ebroker/utils/network/network_availability.dart';
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
    return CupertinoPageRoute(
      builder: (_) => HomeScreen(from: arguments['from'] as String),
    );
  }
}

class HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;

  var isAlreadyShowingLocationDialog = false;

  @override
  void initState() {
    context.read<FetchHomePageDataCubit>().fetch(
          forceRefresh: false,
        );
    context.read<HomePageInfinityScrollCubit>().fetch();

    if (GuestChecker.value == false) {
      context.read<GetApiKeysCubit>().fetch();
    }

    initializeSettings();
    addPageScrollListener();
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

  /// Generic method to handle 'See All' taps for different property types
  ///
  /// This method creates a ViewAllScreen with the appropriate state map and cubit,
  /// navigates to it, and ensures data is loaded if not already available.
  ///
  /// Type parameters:
  /// * [C] - The cubit type that manages the property data
  /// * [S] - The state type associated with the cubit
  /// * [I] - The initial state type
  /// * [P] - The in-progress state type
  /// * [Success] - The success state type (must implement PropertySuccessStateWireframe)
  /// * [F] - The failure state type (must implement PropertyErrorStateWireframe)
  Future<void> _handleSeeAllTap<
      C extends StateStreamable<S>,
      S,
      I,
      P,
      Success extends PropertySuccessStateWireframe,
      F extends PropertyErrorStateWireframe>({
    required String title,
    required C Function() getCubit,
    required bool Function(S state) isSuccessState,
    required Future<void> Function({bool forceRefresh}) fetchData,
  }) async {
    final stateMap = StateMap<I, P, Success, F>();

    ViewAllScreen<C, S>(
      title: title.translate(context),
      map: stateMap,
    ).open(context);

    final cubit = getCubit();
    if (!isSuccessState(cubit.state)) {
      await fetchData(forceRefresh: true);
    }
  }

  Future<void> _onTapPromotedSeeAll({required String title}) async {
    await _handleSeeAllTap<
        FetchPromotedPropertiesCubit,
        FetchPromotedPropertiesState,
        FetchPromotedPropertiesInitial,
        FetchPromotedPropertiesInProgress,
        FetchPromotedPropertiesSuccess,
        FetchPromotedPropertiesFailure>(
      title: title,
      getCubit: () => context.read<FetchPromotedPropertiesCubit>(),
      isSuccessState: (state) => state is FetchPromotedPropertiesSuccess,
      fetchData: ({bool forceRefresh = false}) => context
          .read<FetchPromotedPropertiesCubit>()
          .fetch(forceRefresh: forceRefresh),
    );
  }

  Future<void> _onTapPremiumSeeAll({required String title}) async {
    await _handleSeeAllTap<
        FetchPremiumPropertiesCubit,
        FetchPremiumPropertiesState,
        FetchPremiumPropertiesInitial,
        FetchPremiumPropertiesInProgress,
        FetchPremiumPropertiesSuccess,
        FetchPremiumPropertiesFailure>(
      title: title,
      getCubit: () => context.read<FetchPremiumPropertiesCubit>(),
      isSuccessState: (state) => state is FetchPremiumPropertiesSuccess,
      fetchData: ({bool forceRefresh = false}) => context
          .read<FetchPremiumPropertiesCubit>()
          .fetch(forceRefresh: forceRefresh),
    );
  }

  Future<void> _onTapNearByPropertiesAll({required String title}) async {
    await _handleSeeAllTap<
        FetchNearbyPropertiesCubit,
        FetchNearbyPropertiesState,
        FetchNearbyPropertiesInitial,
        FetchNearbyPropertiesInProgress,
        FetchNearbyPropertiesSuccess,
        FetchNearbyPropertiesFailure>(
      title: title,
      getCubit: () => context.read<FetchNearbyPropertiesCubit>(),
      isSuccessState: (state) => state is FetchNearbyPropertiesSuccess,
      fetchData: ({bool forceRefresh = false}) => context
          .read<FetchNearbyPropertiesCubit>()
          .fetch(forceRefresh: forceRefresh),
    );
  }

  Future<void> _onTapMostLikedAll({required String title}) async {
    await _handleSeeAllTap<
        FetchMostLikedPropertiesCubit,
        FetchMostLikedPropertiesState,
        FetchMostLikedPropertiesInitial,
        FetchMostLikedPropertiesInProgress,
        FetchMostLikedPropertiesSuccess,
        FetchMostLikedPropertiesFailure>(
      title: title,
      getCubit: () => context.read<FetchMostLikedPropertiesCubit>(),
      isSuccessState: (state) => state is FetchMostLikedPropertiesSuccess,
      fetchData: ({bool forceRefresh = false}) => context
          .read<FetchMostLikedPropertiesCubit>()
          .fetch(forceRefresh: forceRefresh),
    );
  }

  Future<void> _onTapMostViewedSeeAll({required String title}) async {
    await _handleSeeAllTap<
        FetchMostViewedPropertiesCubit,
        FetchMostViewedPropertiesState,
        FetchMostViewedPropertiesInitial,
        FetchMostViewedPropertiesInProgress,
        FetchMostViewedPropertiesSuccess,
        FetchMostViewedPropertiesFailure>(
      title: title,
      getCubit: () => context.read<FetchMostViewedPropertiesCubit>(),
      isSuccessState: (state) => state is FetchMostViewedPropertiesSuccess,
      fetchData: ({bool forceRefresh = false}) => context
          .read<FetchMostViewedPropertiesCubit>()
          .fetch(forceRefresh: forceRefresh),
    );
  }

  Future<void> _onTapPersonalizedSeeAll({required String title}) async {
    await _handleSeeAllTap<
        FetchPersonalizedPropertyList,
        FetchPersonalizedPropertyListState,
        FetchPersonalizedPropertyInitial,
        FetchPersonalizedPropertyInProgress,
        FetchPersonalizedPropertySuccess,
        FetchPersonalizedPropertyFail>(
      title: title,
      getCubit: () => context.read<FetchPersonalizedPropertyList>(),
      isSuccessState: (state) => state is FetchPersonalizedPropertySuccess,
      fetchData: ({bool forceRefresh = false}) =>
          context.read<FetchPersonalizedPropertyList>().fetch(
                loadWithoutDelay: true,
                forceRefresh: forceRefresh,
              ),
    );
  }

  Future<void> _onTapChangeLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final placeMark = await Navigator.pushNamed(
      context,
      Routes.chooseLocaitonMap,
      arguments: {
        'from': 'home_location',
      },
    ) as Map?;
    try {
      final latlng = placeMark?['latlng'] as LatLng;
      final place = placeMark?['place'] as Placemark;
      final radius = placeMark?['radius'] as String? ?? '';

      await HiveUtils.setLocation(
        city: place.locality ?? '',
        state: place.administrativeArea ?? '',
        latitude: latlng.latitude.toString(),
        longitude: latlng.longitude.toString(),
        country: place.country ?? '',
        placeId: place.postalCode ?? '',
        radius: radius,
      );
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> _onRefresh() async {
    await CheckInternet.check(
      onInternet: () async {
        await context.read<FetchHomePageDataCubit>().fetch(
              forceRefresh: true,
            );

        await context.read<HomePageInfinityScrollCubit>().fetch();
      },
      onNoInternet: () {
        return HelperUtils.showSnackBarMessage(
          context,
          'noInternet'.translate(context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final homeScreenState = homeStateListener.listen(context);
    HiveUtils.getJWT()?.log('JWT');

    ///
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            UiUtils.getSystemUiOverlayStyle(context: context).copyWith(
          statusBarColor: context.color.primaryColor,
          statusBarIconBrightness: context.color.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
        ),
        backgroundColor: context.color.primaryColor,
        leadingWidth: context.screenWidth * .9,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: EdgeInsetsDirectional.only(
            start: sidePadding.rw(context),
          ),
          child: const LocationWidget(),
        ),
      ),
      backgroundColor: context.color.primaryColor,
      body: CustomRefreshIndicator(
        onRefresh: _onRefresh,
        child: Builder(
          builder: (context) {
            return BlocBuilder<FetchSystemSettingsCubit,
                FetchSystemSettingsState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  controller: homeScreenController,
                  physics: Constant.scrollPhysics,
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).padding.top,
                  ),
                  child: Column(
                    children: [
                      // Fixed sections that should always be at the top
                      const HomeSearchField(), // Search section
                      BlocConsumer<FetchHomePageDataCubit,
                          FetchHomePageDataState>(
                        listener: (context, state) {
                          if (state is FetchHomePageDataSuccess &&
                              state.refreshing != true &&
                              state.homePageDataModel
                                      .homePageLocationDataAvailable ==
                                  false) {
                            showNoDataAtLocation(context);
                          }
                        },
                        builder: (homeContext, homeState) {
                          if (homeState is FetchHomePageDataLoading) {
                            return const HomeShimmer();
                          }
                          if (homeState is FetchHomePageDataSuccess) {
                            final home = homeState.homePageDataModel;
                            return BlocProvider(
                              create: (context) => FetchHomePageDataCubit(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  sliderWidget(
                                    home.sliderSection ?? [],
                                  ), // Slider section

                                  // Dynamic sections from API in their original order

                                  ...(home.originalSections ??
                                          <HomePageSection>[])
                                      .mapIndexed<HomePageSection, Widget>(
                                          (section, index) {
                                    switch (section.type) {
                                      case 'premium_properties_section':
                                        return premiumProperties(
                                          title: home.originalSections?[index]
                                                  .title ??
                                              UiUtils.translate(
                                                context,
                                                'premiumProperties',
                                              ),
                                          premiumProperties:
                                              home.premiumProperties ?? [],
                                        );
                                      case 'categories_section':
                                        return categoryWidget(
                                          categories:
                                              home.categoriesSection ?? [],
                                          title: home.originalSections?[index]
                                                  .title ??
                                              'categories'.translate(context),
                                        );
                                      case 'featured_properties_section':
                                        return featuredProperties(
                                          title: home.originalSections?[index]
                                                  .title ??
                                              UiUtils.translate(
                                                context,
                                                'promotedProperties',
                                              ),
                                          featuredProperties:
                                              home.featuredSection ?? [],
                                        );
                                      case 'most_liked_properties_section':
                                        return mostLikedProperties(
                                          title: home.originalSections?[index]
                                                  .title ??
                                              UiUtils.translate(
                                                context,
                                                'mostLikedProperties',
                                              ),
                                          mostLikedProperties:
                                              home.mostLikedProperties ?? [],
                                        );
                                      case 'most_viewed_properties_section':
                                        return mostViewedProperties(
                                          title: home.originalSections?[index]
                                                  .title ??
                                              UiUtils.translate(
                                                context,
                                                'mostViewed',
                                              ),
                                          mostViewedProperties:
                                              home.mostViewedProperties ?? [],
                                        );
                                      case 'projects_section':
                                        return buildProjects(
                                          title: home.originalSections?[index]
                                                  .title ??
                                              'Project section'
                                                  .translate(context),
                                          projectSection:
                                              home.projectSection ?? [],
                                        );
                                      case 'agents_list_section':
                                        return buildAgents(
                                          title: home.originalSections?[index]
                                                  .title ??
                                              UiUtils.translate(
                                                context,
                                                'agents',
                                              ),
                                          agents: home.agentsList ?? [],
                                        );
                                      case 'nearby_properties_section':
                                        return buildNearByProperties(
                                          title: home.originalSections?[index]
                                                  .title ??
                                              '${UiUtils.translate(
                                                context,
                                                "nearByProperties",
                                              )} (${HiveUtils.getCityName()})',
                                          nearByProperties:
                                              home.nearByProperties ?? [],
                                        );
                                      case 'featured_projects_section':
                                        return buildFeaturedProjects(
                                          title: home.originalSections?[index]
                                                  .title ??
                                              'featuredProjects'
                                                  .translate(context),
                                          projectSection:
                                              home.featuredProjectSection ?? [],
                                        );
                                      case 'user_recommendations_section':
                                        return buildPersonalizedProperty(
                                          title: home.originalSections?[index]
                                                  .title ??
                                              'personalizedFeed'
                                                  .translate(context),
                                          personalizedProperties:
                                              home.personalizedProperties ?? [],
                                        );
                                      case 'properties_by_cities_section':
                                        return popularCityProperties(
                                          title: home.originalSections?[index]
                                                  .title ??
                                              'popularCities'
                                                  .translate(context),
                                          cities: home.propertiesByCities ?? [],
                                        );
                                      default:
                                        return const SizedBox.shrink();
                                    }
                                  }),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          const BannerAdWidget(),
                          allProperties(context: context),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> showNoDataAtLocation(BuildContext context) {
    if (HiveUtils.isGuest()) return Future.value();
    if (isAlreadyShowingLocationDialog) return Future.value();
    isAlreadyShowingLocationDialog = true;
    return UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: 'nodatafound'.translate(context),
        titleColor: context.color.tertiaryColor,
        titleWeight: FontWeight.w600,
        showAcceptButton: false,
        showCancleButton: false,
        svgImagePath: AppIcons.no_data_found,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              'noDataFoundAtThisLocation'.translate(context),
              fontSize: context.font.large,
              color: context.color.textColorDark,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(
              height: 10,
            ),
            UiUtils.buildButton(
              context,
              buttonTitle: 'changeLocation'.translate(context),
              height: 42.rh(context),
              radius: 10,
              onPressed: () async {
                isAlreadyShowingLocationDialog = false;
                Navigator.pop(context);
                await _onTapChangeLocation();
              },
              border: BorderSide(
                color: context.color.borderColor,
              ),
              showElevation: false,
              buttonColor: context.color.primaryColor,
              textColor: context.color.tertiaryColor,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(
              height: 4,
            ),
            UiUtils.buildButton(
              context,
              buttonTitle: 'continue'.translate(context),
              height: 42.rh(context),
              radius: 10,
              showElevation: false,
              onPressed: () {
                isAlreadyShowingLocationDialog = false;
                Navigator.pop(context);
              },
              padding: EdgeInsets.zero,
            ),
          ],
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
          return UiUtils.buildHorizontalShimmer();
        }

        if (state is HomePageInfinityScrollSuccess) {
          if (state.properties.isEmpty) {
            return const SizedBox.shrink();
          }
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
                      horizontal: sidePadding,
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
                      .isLoadingMore())
                    Center(
                      child: UiUtils.progress(
                        height: 30.rh(context),
                        width: 30.rw(context),
                      ),
                    ),
                ],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildProjects({
    required String title,
    required List<ProjectModel> projectSection,
  }) {
    return Column(
      children: [
        if (projectSection.isNotEmpty) ...[
          TitleHeader(
            title: title,
            onSeeAll: () {
              Navigator.pushNamed(
                context,
                Routes.allProjectsScreen,
                arguments: {
                  'isPromoted': false,
                  'title': title,
                },
              );
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

  Widget buildFeaturedProjects({
    required String title,
    required List<ProjectModel> projectSection,
  }) {
    return Column(
      children: [
        if (projectSection.isNotEmpty) ...[
          TitleHeader(
            title: title,
            onSeeAll: () {
              Navigator.pushNamed(
                context,
                Routes.allProjectsScreen,
                arguments: {
                  'isPromoted': true,
                  'title': title,
                },
              );
            },
          ),
          Container(
            alignment: AlignmentDirectional.centerStart,
            height: 250,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: sidePadding),
              itemCount: projectSection.length,
              physics: Constant.scrollPhysics,
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final project = projectSection[index];
                return Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: index == projectSection.length - 1 ? 0 : 10,
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

  Widget buildAgents({
    required String title,
    required List<AgentModel> agents,
  }) {
    if (agents.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleHeader(
            title: title,
            onSeeAll: () {
              Navigator.pushNamed(
                context,
                Routes.agentListScreen,
                arguments: {
                  'title': title,
                },
              );
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

  Widget popularCityProperties({
    required String title,
    required List<City> cities,
  }) {
    if (cities.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleHeader(
            title: title,
            onSeeAll: () {
              Navigator.pushNamed(
                context,
                Routes.cityListScreen,
                arguments: {
                  'title': title,
                },
              );
            },
          ),
          CustomImageGrid(
            cities: cities,
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget mostViewedProperties({
    required String title,
    required List<PropertyModel> mostViewedProperties,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostViewedProperties.isNotEmpty)
          TitleHeader(
            onSeeAll: () async {
              await _onTapMostViewedSeeAll(title: title);
            },
            title: title,
          ),
        buildMostViewedProperties(mostViewedProperties),
      ],
    );
  }

  Widget mostLikedProperties({
    required String title,
    required List<PropertyModel> mostLikedProperties,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostLikedProperties.isNotEmpty) ...[
          TitleHeader(
            onSeeAll: () async {
              await _onTapMostLikedAll(title: title);
            },
            title: title,
          ),
          buildMostLikedProperties(mostLikedProperties),
          const SizedBox(
            height: 15,
          ),
        ],
      ],
    );
  }

  Widget premiumProperties({
    required String title,
    required List<PropertyModel> premiumProperties,
  }) {
    return Column(
      children: [
        if (premiumProperties.isNotEmpty) ...[
          TitleHeader(
            onSeeAll: () async {
              await _onTapPremiumSeeAll(title: title);
            },
            title: title,
          ),
          buildPremiumProperties(premiumProperties),
        ],
      ],
    );
  }

  Widget buildPremiumProperties(List<PropertyModel> premiumProperties) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(
        horizontal: sidePadding,
      ),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        crossAxisCount: 2,
        height: 280,
        crossAxisSpacing: 6,
      ),
      itemCount: premiumProperties.length.clamp(0, 4),
      itemBuilder: (context, index) {
        final property = premiumProperties[index];
        return BlocProvider(
          create: (context) => AddToFavoriteCubitCubit(),
          child: PropertyCardBig(
            isFromCompare: false,
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

  Widget featuredProperties({
    required List<PropertyModel> featuredProperties,
    required String title,
  }) {
    if (featuredProperties.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleHeader(
            onSeeAll: () async {
              await _onTapPromotedSeeAll(title: title);
            },
            title: title,
          ),
          buildPromotedProperties(featuredProperties),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget sliderWidget(List<HomeSlider> banners) {
    if (banners.isNotEmpty) {
      final directionalBanners = Directionality.of(context) == TextDirection.rtl
          ? banners.reversed.toList()
          : banners;
      return Column(
        children: <Widget>[
          SizedBox(
            height: 15.rh(context),
          ),
          CarouselSlider(
            items: directionalBanners.map((e) {
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
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {},
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
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
            CupertinoPageRoute<dynamic>(
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
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: PropertyCardBig(
                key: UniqueKey(),
                isFirst: index == 0,
                property: promotedProperties[index],
                isFromCompare: false,
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
        height: 280,
        crossAxisSpacing: 6,
      ),
      itemCount: mostLiked.length.clamp(0, 4),
      itemBuilder: (context, index) {
        final properties = mostLiked[index];
        return BlocProvider(
          create: (context) => AddToFavoriteCubitCubit(),
          child: PropertyCardBig(
            isFromCompare: false,
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
    required String title,
    required List<PropertyModel> nearByProperties,
  }) {
    if (nearByProperties.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleHeader(
          onSeeAll: () async {
            await _onTapNearByPropertiesAll(title: title);
          },
          title: title,
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
        height: 280,
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
            isFromCompare: false,
            property: property,
          ),
        );
      },
    );
  }

  Widget categoryWidget({
    required List<Category> categories,
    required String title,
  }) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TitleHeader(
          title: title,
          enableShowAll: true,
          onSeeAll: () {
            Navigator.pushNamed(context, Routes.categories);
          },
        ),
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

  Widget buildPersonalizedProperty({
    required String title,
    required List<PropertyModel> personalizedProperties,
  }) {
    if (personalizedProperties.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleHeader(
          onSeeAll: () async {
            await _onTapPersonalizedSeeAll(title: title);
          },
          title: title,
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            itemCount: personalizedProperties.length.clamp(0, 6),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: sidePadding,
            ),
            physics: Constant.scrollPhysics,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              var propertyModel = personalizedProperties[index];
              propertyModel =
                  context.watch<PropertyEditCubit>().get(propertyModel);
              return BlocProvider(
                create: (context) {
                  return AddToFavoriteCubitCubit();
                },
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: 10,
                  ),
                  child: PropertyCardBig(
                    key: UniqueKey(),
                    showEndPadding: true,
                    isFromCompare: false,
                    isFirst: index == 0,
                    property: propertyModel,
                    onLikeChange: (type) {
                      if (type == FavoriteType.add) {
                        context.read<FetchFavoritesCubit>().add(propertyModel);
                      } else {
                        context
                            .read<FetchFavoritesCubit>()
                            .remove(personalizedProperties[index].id);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
