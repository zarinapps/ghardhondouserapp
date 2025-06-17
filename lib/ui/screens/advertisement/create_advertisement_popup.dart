import 'package:ebroker/data/cubits/property/create_advertisement_cubit.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/Widgets/property_card_big.dart';
import 'package:ebroker/ui/screens/home/widgets/project_card_horizontal.dart';
import 'package:ebroker/ui/screens/project/view/project_card_big.dart';
import 'package:ebroker/utils/imagePicker.dart';
import 'package:flutter/material.dart';

class CreateAdvertisementPopup extends StatefulWidget {
  const CreateAdvertisementPopup({
    required this.property,
    required this.isProject,
    required this.project,
    super.key,
  });
  final PropertyModel property;
  final bool isProject;
  final ProjectModel project;

  @override
  State<CreateAdvertisementPopup> createState() =>
      _CreateAdvertisementPopupState();
}

class _CreateAdvertisementPopupState extends State<CreateAdvertisementPopup> {
  final PickImage _pickImage = PickImage();
  final String advertisementType = 'home';
  bool hasPackage = false;
  late final PageController _pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          pageIndex = (_pageController.page ?? 0).round();
        });
      }
    });
    Future.delayed(Duration.zero, () {
      context.read<GetSubsctiptionPackageLimitsCubit>().getLimits(
            packageType: 'property_feature',
          );
    });
  }

  @override
  void dispose() {
    _pickImage.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget getPreview({required int index}) {
    return Container(
      alignment: Alignment.center,
      margin: index == 0
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 24),
      child: index == 0 && widget.isProject != true
          ? PropertyCardBig(
              isFromCompare: false,
              showLikeButton: false,
              disableTap: true,
              showFeatured: true,
              property: widget.property,
            )
          : index != 0 && widget.isProject != true
              ? PropertyHorizontalCard(
                  showFeatured: true,
                  showLikeButton: false,
                  disableTap: true,
                  property: widget.property,
                )
              : index == 0 && widget.isProject == true
                  ? ProjectCardBig(
                      showFeatured: true,
                      disableTap: true,
                      project: widget.project,
                    )
                  : ProjectHorizontalCard(
                      showFeatured: true,
                      disableTap: true,
                      isRejected: false,
                      project: widget.project,
                    ),
    );
  }

  Future<void> _createAdvertisement() async {
    await context.read<CreateAdvertisementCubit>().create(
          featureFor: widget.isProject == true ? 'project' : 'property',
          projectId: widget.project.id.toString(),
          propertyId: widget.property.id.toString(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.63,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        backgroundColor: context.color.backgroundColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: 16,
                          top: 16,
                        ),
                        child: CustomText(
                          UiUtils.translate(context, 'createAdvertisment'),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: const EdgeInsetsDirectional.only(
                            top: 16,
                            end: 16,
                            start: 16,
                          ),
                          alignment: Alignment.center,
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: context.color.inverseSurface
                                    .withValues(alpha: 0.3),
                                blurRadius: 1,
                              ),
                            ],
                            color: context.color.secondaryColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: context.color.tertiaryColor,
                            weight: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocConsumer<CreateAdvertisementCubit,
                      CreateAdvertisementState>(
                    listener: (context, state) {
                      if (state is CreateAdvertisementInProgress) {
                        Widgets.showLoader(context);
                      }
                      if (state is CreateAdvertisementFailure) {
                        Widgets.hideLoder(context);
                        Navigator.pop(context);
                        HelperUtils.showSnackBarMessage(
                          context,
                          UiUtils.translate(context, state.errorMessage),
                          type: MessageType.warning,
                        );
                      }
                      if (state is CreateAdvertisementSuccess) {
                        Widgets.hideLoder(context);
                        Navigator.pop(context);
                        HelperUtils.showSnackBarMessage(
                          context,
                          state.message,
                          type: MessageType.success,
                        );
                      }
                    },
                    builder: (context, state) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 300,
                        child: Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                itemCount: 2,
                                physics: Constant.scrollPhysics,
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() {
                                    if (index == 0) {
                                      index = 1;
                                    }
                                    if (index == 1) {
                                      index = 0;
                                    }
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return getPreview(index: index);
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            // Add the indicator
                            Container(
                              width: 50,
                              decoration: BoxDecoration(
                                color: context.color.secondaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  2,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: index == pageIndex
                                          ? context.color.tertiaryColor
                                          : context.color.shadow
                                              .withValues(alpha: 0.3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  BlocConsumer<GetSubsctiptionPackageLimitsCubit,
                      GetSubscriptionPackageLimitsState>(
                    listener: (context, state) {
                      if (state is GetSubsctiptionPackageLimitsFailure) {
                        UiUtils.showBlurredDialoge(
                          context,
                          dialog: BlurredDialogBox(
                            title: state.errorMessage.firstUpperCase(),
                            isAcceptContainesPush: true,
                            onAccept: () async {
                              await Navigator.popAndPushNamed(
                                context,
                                Routes.subscriptionPackageListRoute,
                                arguments: {
                                  'from': 'propertyDetails',
                                  'isBankTransferEnabled': (context
                                              .read<GetApiKeysCubit>()
                                              .state as GetApiKeysSuccess)
                                          .bankTransferStatus ==
                                      '1',
                                },
                              );
                            },
                            content: CustomText(
                              'yourPackageLimitOver'.translate(context),
                            ),
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is GetSubscriptionPackageLimitsSuccess) {
                        hasPackage = state.hasSubscription == true;
                      }
                      return Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: UiUtils.buildButton(
                                context,
                                buttonColor: context.color.primaryColor,
                                border: BorderSide(
                                  color: context.color.tertiaryColor
                                      .withValues(alpha: 0.5),
                                ),
                                textColor: context.color.tertiaryColor,
                                onPressed: () {
                                  UiUtils.showBlurredDialoge(
                                    context,
                                    dialog: BlurredDialogBox(
                                      title: 'advertiseProperty'
                                          .translate(context),
                                      content: CustomText(
                                        'advertisementDescription'
                                            .translate(context),
                                      ),
                                      showCancleButton: false,
                                      acceptTextColor:
                                          context.color.buttonColor,
                                    ),
                                  );
                                },
                                prefixWidget: Container(
                                  margin:
                                      const EdgeInsetsDirectional.only(end: 8),
                                  child: Icon(
                                    Icons.info_outline,
                                    color: context.color.tertiaryColor,
                                  ),
                                ),
                                buttonTitle: UiUtils.translate(context, 'info'),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: UiUtils.buildButton(
                                context,
                                onPressed: () {
                                  if (hasPackage) {
                                    _createAdvertisement();
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.subscriptionPackageListRoute,
                                      arguments: {
                                        'isBankTransferEnabled': (context
                                                    .read<GetApiKeysCubit>()
                                                    .state as GetApiKeysSuccess)
                                                .bankTransferStatus ==
                                            '1',
                                      },
                                    );
                                  }
                                },
                                prefixWidget: hasPackage
                                    ? Container(
                                        margin:
                                            const EdgeInsetsDirectional.only(
                                          end: 8,
                                        ),
                                        child: UiUtils.getSvg(
                                          AppIcons.promoted,
                                        ),
                                      )
                                    : Icon(
                                        Icons.lock,
                                        color: context.color.buttonColor,
                                      ),
                                buttonTitle: hasPackage
                                    ? UiUtils.translate(context, 'promote')
                                    : UiUtils.translate(
                                        context,
                                        'subscribe',
                                      ),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
