import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

enum PropertyAddType { project, property }

class SelectPropertyType extends StatefulWidget {
  const SelectPropertyType({required this.type, super.key});
  final PropertyAddType type;

  static Route route(RouteSettings settings) {
    final arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return SelectPropertyType(
          type: arguments?['type'],
        );
      },
    );
  }

  @override
  State<SelectPropertyType> createState() => _SelectPropertyTypeState();
}

class _SelectPropertyTypeState extends State<SelectPropertyType> {
  int? selectedIndex;
  Category? selectedCategory;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Widgets.showLoader(context);
    });
    Future.delayed(
      const Duration(seconds: 2),
      () {
        context.read<GetSubsctiptionPackageLimitsCubit>().getLimits(
              type: 'property',
            );
      },
    );
    context.read<FetchOutdoorFacilityListCubit>().fetch();
  }

  void _openSubscriptionScreen() {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      Routes.subscriptionPackageListRoute,
    ).then((value) {
      // Navigator.pop(context);
      context.read<GetSubsctiptionPackageLimitsCubit>().getLimits(
            type: 'property',
          );

      // Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: widget.type == PropertyAddType.property
            ? 'ddPropertyLbl'.translate(context)
            : 'projectType'.translate(context),
        actions: const [
          Spacer(),
          CustomText('1/4'),
          SizedBox(
            width: 14,
          ),
        ],
        showBackButton: true,
      ),
      bottomNavigationBar: ColoredBox(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: UiUtils.buildButton(
            context,
            disabledColor: Colors.grey,
            onTapDisabledButton: () {
              HelperUtils.showSnackBarMessage(
                context,
                'pleaseSelectCategory'.translate(context),
                isFloating: true,
              );
            },
            disabled: selectedCategory == null,
            onPressed: () {
              final state =
                  context.read<GetSubsctiptionPackageLimitsCubit>().state;
              if (state is! GetSubscriptionPackageLimitsInProgress) {
                Constant.addProperty.addAll({'category': selectedCategory});

                if (selectedCategory != null) {
                  if (widget.type == PropertyAddType.property) {
                    Navigator.pushNamed(
                      context,
                      Routes.addPropertyDetailsScreen,
                    );
                  } else {
                    Navigator.pushNamed(context, Routes.addProjectDetails);
                  }
                }
              }
            },
            height: 48.rh(context),
            fontSize: context.font.large,
            buttonTitle: UiUtils.translate(context, 'continue'),
          ),
        ),
      ),
      body: BlocListener<GetSubsctiptionPackageLimitsCubit,
          GetSubscriptionPackageLimitsState>(
        bloc: context.read<GetSubsctiptionPackageLimitsCubit>(),
        listener: (context, state) {
          if (state is GetSubscriptionPackageLimitsInProgress) {
            Widgets.showLoader(context);
          }
          if (state is GetSubsctiptionPackageLimitsFailure) {
            Widgets.hideLoder(context);
            HelperUtils.showSnackBarMessage(
              context,
              state.errorMessage.firstUpperCase(),
              onClose: () {
                Navigator.pop(context);
              },
            );
          }
          if (state is GetSubscriptionPackageLimitsSuccess) {
            if (state.hasSubscription == false) {
              Widgets.hideLoder(context);
              UiUtils.showBlurredDialoge(
                context,
                sigmaX: 3,
                sigmaY: 3,
                dialoge: BlurredDialogBox(
                  isAcceptContainesPush: true,
                  acceptButtonName: UiUtils.translate(context, 'subscribe'),
                  backAllowedButton: false,
                  title: UiUtils.translate(context, 'packageNotValid'),
                  content: CustomText(
                    UiUtils.translate(context, 'packageNotForProperty'),
                  ),
                  onCancel: () {
                    Navigator.pop(context);
                  },
                  onAccept: () async {
                    _openSubscriptionScreen();
                  },
                ),
              );
            } else {
              Widgets.hideLoder(context);
            }
          }
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 20,
                  end: 20,
                  top: 20,
                ),
                child: CustomText(
                  UiUtils.translate(context, 'typeOfProperty'),
                  color: context.color.textColorDark,
                ),
              ),
              BlocBuilder<FetchCategoryCubit, FetchCategoryState>(
                builder: (context, state) {
                  if (state is FetchCategoryInProgress) {}
                  if (state is FetchCategoryFailure) {
                    return Center(
                      child: CustomText(state.errorMessage),
                    );
                  }
                  if (state is FetchCategorySuccess) {
                    return GridView.builder(
                      itemCount: state.categories.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(20),
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) {
                        return buildTypeCard(
                          index,
                          context,
                          state.categories[index],
                        );
                      },
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTypeCard(int index, BuildContext context, Category category) {
    return GestureDetector(
      onTap: () {
        selectedCategory = category;
        selectedIndex = index;
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: (selectedIndex == index)
              ? context.color.tertiaryColor
              : context.color.secondaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: (selectedIndex == index)
              ? [
                  BoxShadow(
                    offset: const Offset(1, 2),
                    blurRadius: 5,
                    color: context.color.tertiaryColor,
                  ),
                ]
              : null,
          border: (selectedIndex == index)
              ? null
              : Border.all(color: context.color.borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 25.rh(context),
              width: 25.rw(context),
              child: UiUtils.imageType(
                category.image!,
                color: selectedIndex == index
                    ? context.color.secondaryColor
                    : (Constant.adaptThemeColorSvg
                        ? context.color.tertiaryColor
                        : null),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: CustomText(category.category!,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  color: selectedIndex == index
                      ? context.color.secondaryColor
                      : context.color.tertiaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
