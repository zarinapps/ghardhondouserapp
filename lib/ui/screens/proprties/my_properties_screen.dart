import 'package:ebroker/data/cubits/favorite/add_to_favorite_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_my_properties_cubit.dart';
import 'package:ebroker/ui/screens/home/widgets/custom_refresh_indicator.dart';
import 'package:ebroker/ui/screens/home/widgets/property_horizontal_card.dart';
import 'package:ebroker/ui/screens/widgets/errors/no_data_found.dart';
import 'package:ebroker/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

int propertyScreenCurrentPage = 0;
ValueNotifier<Map<String, dynamic>> emptyCheckNotifier =
    ValueNotifier({'isSellEmpty': false, 'isRentEmpty': false});

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => MyPropertyState();
}

enum FilterType { status, propertyType }

class MyPropertyState extends State<PropertiesScreen>
    with TickerProviderStateMixin {
  int offset = 0;
  int total = 0;
  bool isSellEmpty = false;
  bool isRentEmpty = false;
  final controller = ScrollController();
  String selectedType = '';
  String selectedStatus = '';
  // Track temporary filter selections
  late String tempSelectedType;
  late String tempSelectedStatus;

  @override
  void initState() {
    tempSelectedType = selectedType;
    tempSelectedStatus = selectedStatus;
    if (context.read<FetchMyPropertiesCubit>().state
        is! FetchMyPropertiesSuccess) {
      fetchMyProperties();
    }

    addScrollListener();
    super.initState();
  }

  void addScrollListener() {
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (context.read<FetchMyPropertiesCubit>().hasMoreData()) {
          context.read<FetchMyPropertiesCubit>().fetchMoreProperties(
                type: selectedType.toLowerCase(),
                status: selectedStatus.toLowerCase(),
              );
        }
      }
    });
  }

  Future<void> fetchMyProperties() async {
    await context.read<FetchMyPropertiesCubit>().fetchMyProperties(
          type: selectedType.toLowerCase(),
          status: selectedStatus.toLowerCase(),
        );
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
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(
          context,
          title: UiUtils.translate(context, 'myProperty'),
          hideTopBorder: true,
          actions: [
            GestureDetector(
              onTap: show,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: UiUtils.getSvg(
                  AppIcons.filter,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
          ],
        ),
        body: CustomRefreshIndicator(
          onRefresh: () async {
            await fetchMyProperties();
          },
          child: BlocBuilder<FetchMyPropertiesCubit, FetchMyPropertiesState>(
            builder: (context, state) {
              if (state is FetchMyPropertiesInProgress) {
                return UiUtils.buildHorizontalShimmer();
              }
              if (state is FetchMyPropertiesFailure) {}
              if (state is FetchMyPropertiesSuccess &&
                  state.myProperty.isEmpty) {
                return NoDataFound(
                  onTap: fetchMyProperties,
                );
              }
              if (state is FetchMyPropertiesSuccess &&
                  state.myProperty.isNotEmpty) {
                return ListView.separated(
                  physics: Constant.scrollPhysics,
                  controller: controller,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                  itemCount:
                      state.myProperty.length + (state.isLoadingMore ? 1 : 0),
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 2,
                    );
                  },
                  itemBuilder: (context, index) {
                    if (index >= state.myProperty.length) {
                      if (state.isLoadingMore) {
                        return Center(
                          child: UiUtils.progress(),
                        );
                      }
                      return const SizedBox();
                    }
                    final property = state.myProperty[index];
                    final status =
                        property.requestStatus.toString() == 'approved'
                            ? property.status.toString()
                            : property.requestStatus.toString();
                    return BlocProvider(
                      create: (context) => AddToFavoriteCubitCubit(),
                      child: PropertyHorizontalCard(
                        property: property,
                        showLikeButton: false,
                        statusButton: StatusButton(
                          lable: statusText(status),
                          color: statusColor(status).withValues(alpha: 0.2),
                          textColor: statusColor(status),
                        ),
                        // useRow: true,
                      ),
                    );
                  },
                );
              }
              return const SomethingWentWrong();
            },
          ),
        ),
      ),
    );
  }

  void show() {
    // Reset temporary selections to current values when opening filter
    tempSelectedType = selectedType;
    tempSelectedStatus = selectedStatus;
    showModalBottomSheet<dynamic>(
      context: context,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: context.color.secondaryColor,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.only(left: 18, right: 18, bottom: 18),
              color: context.color.secondaryColor,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    'filterTitle'.translate(context),
                    color: context.color.inverseSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    'status'.translate(context),
                    color: context.color.inverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    runSpacing: 8,
                    children: [
                      buildFilterCheckbox(
                        'all'.translate(context),
                        tempSelectedStatus,
                        '',
                        FilterType.status,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'approved'.translate(context),
                        tempSelectedStatus,
                        'approved',
                        FilterType.status,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'rejected'.translate(context),
                        tempSelectedStatus,
                        'rejected',
                        FilterType.status,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'pending'.translate(context),
                        tempSelectedStatus,
                        'pending',
                        FilterType.status,
                        setModalState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    'type'.translate(context),
                    color: context.color.inverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    runSpacing: 8,
                    children: [
                      buildFilterCheckbox(
                        'all'.translate(context),
                        tempSelectedType,
                        '',
                        FilterType.propertyType,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'sell'.translate(context),
                        tempSelectedType,
                        'sell',
                        FilterType.propertyType,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'rent'.translate(context),
                        tempSelectedType,
                        'rent',
                        FilterType.propertyType,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'sold'.translate(context),
                        tempSelectedType,
                        'sold',
                        FilterType.propertyType,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'rented'.translate(context),
                        tempSelectedType,
                        'rented',
                        FilterType.propertyType,
                        setModalState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  UiUtils.buildButton(
                    context,
                    onPressed: () async {
                      // Apply the temporary selections
                      setState(() {
                        selectedType = tempSelectedType;
                        selectedStatus = tempSelectedStatus;
                      });

                      // Close the modal
                      Navigator.pop(context);

                      // Fetch properties with new filters
                      await fetchMyProperties();
                    },
                    height: 50,
                    buttonTitle: 'applyFilter'.translate(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildFilterCheckbox(
    String title,
    String currentValue,
    String optionValue,
    FilterType filterType,
    StateSetter setModalState,
  ) {
    final isSelected = currentValue.toLowerCase() == optionValue.toLowerCase();

    return GestureDetector(
      onTap: () {
        setModalState(() {
          switch (filterType) {
            case FilterType.status:
              tempSelectedStatus = optionValue.toLowerCase();
            case FilterType.propertyType:
              tempSelectedType = optionValue.toLowerCase();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? context.color.tertiaryColor
                : context.color.borderColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? context.color.tertiaryColor
              : context.color.primaryColor,
        ),
        child: CustomText(
          title,
          color: isSelected
              ? context.color.buttonColor
              : context.color.inverseSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    );
  }
}
