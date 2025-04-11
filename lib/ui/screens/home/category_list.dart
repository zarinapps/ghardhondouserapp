import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/admob/bannerAdLoadWidget.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key, this.from});
  final String? from;

  @override
  State<CategoryList> createState() => _CategoryListState();

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return BlurredRouter(
      builder: (_) => CategoryList(from: args?['from']),
    );
  }
}

class _CategoryListState extends State<CategoryList>
    with TickerProviderStateMixin {
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    _pageScrollController.addListener(() {
      if (_pageScrollController.isEndReached()) {
        if (context.read<FetchCategoryCubit>().hasMoreData()) {
          context.read<FetchCategoryCubit>().fetchCategoriesMore();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'categoriesLbl'),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
        builder: (context, state) {
          if (state is FetchCategoryInProgress) {
            return UiUtils.progress();
          }
          if (state is FetchCategorySuccess) {
            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    controller: _pageScrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    itemCount: state.categories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 3.5),
                    ),
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      return Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: InkWell(
                          onTap: () {
                            if (widget.from == Routes.filterScreen) {
                              Navigator.pop(context, category);
                            } else {
                              Constant.propertyFilter = null;
                              HelperUtils.goToNextPage(
                                Routes.propertiesList,
                                context,
                                false,
                                args: {
                                  'catID': category.id,
                                  'catName': category.category,
                                },
                              ); //pass current index category id & name here
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.color.secondaryColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 1.5,
                                color: context.color.borderColor,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 50,
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: UiUtils.imageType(
                                    category.image!,
                                    color: Constant.adaptThemeColorSvg
                                        ? context.color.tertiaryColor
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                CustomText(
                                  category.category!,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
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
