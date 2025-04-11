import 'package:ebroker/data/cubits/delete_advertisment_cubit.dart';
import 'package:ebroker/data/cubits/project/fetch_my_promoted_projects.dart';
import 'package:ebroker/data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/repositories/advertisement_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/advertisement_horizontal_card.dart';
import 'package:flutter/material.dart';

class MyAdvertisementScreen extends StatefulWidget {
  const MyAdvertisementScreen({super.key});
  static Route<dynamic> route(RouteSettings routeSettings) {
    return BlurredRouter(
      builder: (_) => const MyAdvertisementScreen(),
    );
  }

  @override
  State<MyAdvertisementScreen> createState() => _MyAdvertisementScreenState();
}

class _MyAdvertisementScreenState extends State<MyAdvertisementScreen>
    with TickerProviderStateMixin {
  final ScrollController _propertiesScrollController = ScrollController();
  final ScrollController _projectsScrollController = ScrollController();
  late TabController _tabController;
  Map<int, String>? statusMap;
  String advertisementType = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    context.read<FetchMyPromotedPropertysCubit>().fetchMyPromotedPropertys();
    context.read<FetchMyPromotedProjectsCubit>().fetchMyPromotedProjects();

    Future.delayed(
      Duration.zero,
      () {
        statusMap = {
          0: UiUtils.translate(context, 'approved'),
          1: UiUtils.translate(context, 'pending'),
          2: UiUtils.translate(context, 'rejected'),
          3: UiUtils.translate(context, 'expired'),
        };
      },
    );

    _propertiesScrollController.addListener(_propertiesScroll);
    _projectsScrollController.addListener(_projectsScroll);
  }

  void _handleTabChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _propertiesScrollController.dispose();
    _projectsScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _propertiesScroll() {
    if (_propertiesScrollController.isEndReached()) {
      if (context.read<FetchMyPromotedPropertysCubit>().hasMoreData()) {
        context
            .read<FetchMyPromotedPropertysCubit>()
            .fetchMyPromotedPropertysMore();
      }
    }
  }

  void _projectsScroll() {
    if (_projectsScrollController.isEndReached()) {
      if (context.read<FetchMyPromotedProjectsCubit>().hasMoreData()) {
        // context
        //     .read<FetchMyPromotedProjectsCubit>()
        //     .fetchMyPromotedProjectsMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'myAds'),
        bottomHeight: 50,
        bottom: [
          TabBar(
            controller: _tabController,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            indicatorColor: context.color.tertiaryColor,
            labelColor: context.color.tertiaryColor,
            unselectedLabelColor: context.color.textColorDark,
            tabs: [
              Tab(text: UiUtils.translate(context, 'properties')),
              Tab(text: UiUtils.translate(context, 'projects')),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPropertiesTab(),
          _buildProjectsTab(),
        ],
      ),
    );
  }

  Widget _buildPropertiesTab() {
    return RefreshIndicator(
      color: context.color.tertiaryColor,
      onRefresh: () async {
        await context
            .read<FetchMyPromotedPropertysCubit>()
            .fetchMyPromotedPropertys();
      },
      child: BlocBuilder<FetchMyPromotedPropertysCubit,
          FetchMyPromotedPropertysState>(
        builder: (context, state) {
          if (state is FetchMyPromotedPropertysInProgress) {
            return Center(child: UiUtils.progress());
          }
          if (state is FetchMyPromotedPropertysFailure) {
            return SingleChildScrollView(
              physics: Constant.scrollPhysics,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: const SomethingWentWrong(),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                ],
              ),
            );
          }
          if (state is FetchMyPromotedPropertysSuccess) {
            if (state.advertisement.isEmpty) {
              return NoDataFound(
                title: 'noFeaturedAdsYes'.translate(context),
                description: 'noFeaturedDescription'.translate(context),
                onTap: () {
                  context
                      .read<FetchMyPromotedPropertysCubit>()
                      .fetchMyPromotedPropertys();
                  setState(() {});
                },
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: Constant.scrollPhysics,
                    controller: _propertiesScrollController,
                    padding: const EdgeInsets.all(20),
                    itemBuilder: (context, index) {
                      final model = state.advertisement[index];
                      return _buildAdvertisementPropertyCard(
                        context,
                        model,
                        isProperty: true,
                      );
                    },
                    itemCount: state.advertisement.length,
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

  Widget _buildProjectsTab() {
    return RefreshIndicator(
      color: context.color.tertiaryColor,
      onRefresh: () async {
        await context
            .read<FetchMyPromotedProjectsCubit>()
            .fetchMyPromotedProjects();
      },
      child: BlocBuilder<FetchMyPromotedProjectsCubit,
          FetchMyPromotedProjectsState>(
        builder: (context, state) {
          if (state is FetchMyPromotedProjectsInProgress) {
            return Center(child: UiUtils.progress());
          }
          if (state is FetchMyPromotedProjectsFailure) {
            return SingleChildScrollView(
              physics: Constant.scrollPhysics,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: const SomethingWentWrong(),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                  ),
                ],
              ),
            );
          }
          if (state is FetchMyPromotedProjectsSuccess) {
            if (state.advertisement.isEmpty) {
              return NoDataFound(
                title: 'noFeaturedProjectsYet'.translate(context),
                description: 'noFeaturedProjectsDescription'.translate(context),
                onTap: () {
                  context
                      .read<FetchMyPromotedProjectsCubit>()
                      .fetchMyPromotedProjects();
                  setState(() {});
                },
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    physics: Constant.scrollPhysics,
                    controller: _projectsScrollController,
                    padding: const EdgeInsets.all(20),
                    itemBuilder: (context, index) {
                      final model = state.advertisement[index];
                      return _buildAdvertisementProjectCard(
                        context,
                        model,
                        isProperty: false,
                      );
                    },
                    itemCount: state.advertisement.length,
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

  Widget _buildAdvertisementPropertyCard(
    BuildContext context,
    AdvertisementProperty advertisement, {
    required bool isProperty,
  }) {
    return BlocProvider(
      create: (context) => DeleteAdvertismentCubit(AdvertisementRepository()),
      child: MyAdvertisementPropertyHorizontalCard(
        advertisement: advertisement,
        showLikeButton: false,
        statusButton: StatusButton(
          lable: statusMap![advertisement.status].toString().firstUpperCase(),
          color: statusColor(advertisement.status),
          textColor: context.color.buttonColor,
        ),
        showDeleteButton: true,
        // isProperty: isProperty,
      ),
    );
  }

  Widget _buildAdvertisementProjectCard(
    BuildContext context,
    AdvertisementProject advertisement, {
    required bool isProperty,
  }) {
    return BlocProvider(
      create: (context) => DeleteAdvertismentCubit(AdvertisementRepository()),
      child: MyAdvertisementProjectHorizontalCard(
        advertisement: advertisement,
        showLikeButton: false,
        statusButton: StatusButton(
          lable: statusMap![advertisement.status].toString().firstUpperCase(),
          color: statusColor(advertisement.status),
          textColor: context.color.buttonColor,
        ),
        showDeleteButton: true,
        // isProperty: isProperty,
      ),
    );
  }

  Color statusColor(int status) {
    if (status == 0) {
      return Colors.green;
    } else if (status == 1) {
      return Colors.orangeAccent;
    } else if (status == 2) {
      return Colors.red;
    } else if (status == 3) {
      return Colors.redAccent;
    }
    return Colors.transparent;
  }
}
