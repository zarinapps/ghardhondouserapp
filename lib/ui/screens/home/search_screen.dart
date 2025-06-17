import 'dart:developer';

import 'package:ebroker/data/cubits/Utility/fetch_facilities_cubit.dart';
import 'package:ebroker/data/helper/filter.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/admob/banner_ad_load_widget.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    required this.autoFocus,
    super.key,
  });
  final bool autoFocus;
  static Route<dynamic> route(RouteSettings settings) {
    final arguments = settings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (context) {
        return SearchScreen(
          autoFocus: arguments?['autoFocus'] as bool? ?? false,
        );
      },
    );
  }

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<SearchScreen> {
  @override
  bool get wantKeepAlive => true;
  bool isFocused = false;
  String previouseSearchQuery = '';
  static TextEditingController searchController = TextEditingController();
  int offset = 0;
  late ScrollController controller;
  List<PropertyModel> propertylist = [];
  List<dynamic> idlist = [];
  Timer? _searchDelay;
  FilterApply? selectedFilter;
  bool showContent = true;
  @override
  void initState() {
    super.initState();
    context.read<SearchPropertyCubit>().searchProperty(
          '',
          offset: 0,
          filter: selectedFilter,
        );
    searchController = TextEditingController();
    searchController.addListener(searchPropertyListener);
    controller = ScrollController()..addListener(pageScrollListen);
  }

  void pageScrollListen() {
    if (controller.isEndReached()) {
      if (context.read<SearchPropertyCubit>().hasMoreData()) {
        context.read<SearchPropertyCubit>().fetchMoreSearchData();
      }
    }
  }

//this will listen and manage search
  void searchPropertyListener() {
    _searchDelay?.cancel();
    searchCallAfterDelay();
  }

//This will create delay so we don't face rapid api call
  void searchCallAfterDelay() {
    _searchDelay = Timer(const Duration(milliseconds: 500), propertySearch);
  }

  ///This will call api after some delay
  void propertySearch() {
    // if (searchController.text.isNotEmpty) {
    if (previouseSearchQuery != searchController.text) {
      context.read<SearchPropertyCubit>().searchProperty(
            searchController.text,
            offset: 0,
            filter: selectedFilter,
          );
      previouseSearchQuery = searchController.text;
    }
    // } else {
    // context.read<SearchPropertyCubit>().clearSearch();
    // }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        leading: const SizedBox.shrink(),
        actions: [
          searchTextField(),
        ],
        // leading: searchTextField(),
      ),
      bottomNavigationBar: const BottomAppBar(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<SearchPropertyCubit, SearchPropertyState>(
              builder: (context, state) {
                return listWidget(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget listWidget(SearchPropertyState state) {
    if (state is SearchPropertyFetchProgress) {
      return UiUtils.buildHorizontalShimmer();
    }
    if (state is SearchPropertyFailure) {
      if (state.errorMessage is NoInternetConnectionError) {
        return NoInternet(
          onRetry: () {
            context.read<SearchPropertyCubit>().searchProperty(
                  '',
                  offset: 0,
                  filter: selectedFilter,
                );
          },
        );
      }

      return const SomethingWentWrong();
    }

    if (state is SearchPropertySuccess) {
      if (state.searchedroperties.isEmpty) {
        return Center(
          child: CustomText(
            UiUtils.translate(context, 'nodatafound'),
          ),
        );
      }
      return SingleChildScrollView(
        controller: controller,
        physics: Constant.scrollPhysics,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Wrap(
                children:
                    List.generate(state.searchedroperties.length, (index) {
                  final property = state.searchedroperties[index];
                  final propertiesList = state.searchedroperties;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: PropertyHorizontalCard(
                      property: property,
                      properties: propertiesList,
                      isFromSearch: true,
                    ),
                  );
                }),
              ),
              if (state.isLoadingMore) UiUtils.progress(),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  Widget setSearchIcon() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: UiUtils.getSvg(
        AppIcons.search,
        color: context.color.tertiaryColor,
      ),
    );
  }

  Widget setSuffixIcon() {
    return GestureDetector(
      onTap: () {
        searchController.clear();
        isFocused = false; //set icon color to black back
        FocusScope.of(context).unfocus(); //dismiss keyboard
        setState(() {});
      },
      child: Icon(
        Icons.close_rounded,
        color: Theme.of(context).colorScheme.blackColor,
        size: 30,
      ),
    );
  }

  Widget searchTextField() {
    final facilitiesState = context.watch<FetchFacilitiesCubit>().state;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 250.rw(context),
          height: 50.rh(context),
          alignment: Alignment.center,
          child: TextFormField(
            controller: searchController,
            decoration: InputDecoration(
              border: InputBorder.none, //OutlineInputBorder()
              fillColor: Theme.of(context).colorScheme.secondaryColor,
              hintText: UiUtils.translate(context, 'searchHintLbl'),
              hintStyle: TextStyle(
                color: context.color.inverseSurface.withValues(alpha: 0.5),
              ),
              prefixIcon: setSearchIcon(),
              prefixIconConstraints:
                  const BoxConstraints(minHeight: 5, minWidth: 5),
            ),
            onTapOutside: (_) {
              isFocused = false;
              FocusScope.of(context).unfocus();
              setState(() {
                isFocused = false;
                FocusScope.of(context).unfocus();
              });
            },
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        GestureDetector(
          onTap: () async {
            try {
              await context.read<FetchFacilitiesCubit>().fetch();
              if (context.read<FetchFacilitiesCubit>().state
                  is FetchFacilitiesSuccess) {
                await Navigator.pushNamed(
                  context,
                  Routes.filterScreen,
                  arguments: {
                    'filter': selectedFilter,
                  },
                ).then((value) {
                  if (value != null) {
                    selectedFilter = value as FilterApply;
                    context.read<SearchPropertyCubit>().searchProperty(
                          searchController.text,
                          offset: 0,
                          filter: value,
                        );
                    setState(() {});

                    // context.read<SearchPropertyCubit>().searchProperty(
                    //     searchController.text,
                    //     offset: 0,
                    //     filter: selectedFilter);
                  }
                });
              }
            } catch (e, st) {
              log('error is $e stack is $st');
            }
          },
          child: SizedBox(
            width: 50.rw(context),
            height: 50.rh(context),
            child: facilitiesState is FetchFacilitiesLoading
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: UiUtils.progress(),
                  )
                : Center(
                    child: UiUtils.getSvg(
                      AppIcons.filter,
                      color: context.color.tertiaryColor,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
