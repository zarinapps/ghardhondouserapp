import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

mixin BlurDialoge {}

///This dialog box will blur background of screen
///This is normally a screen which blurs its background we don't show builtin dialog box here instead we push to new route and show container in middle of screen
class BlurredDialogBox extends StatelessWidget implements BlurDialoge {
  const BlurredDialogBox({
    required this.title,
    required this.content,
    super.key,
    this.showAcceptButton = true,
    this.cancelButtonName,
    this.acceptButtonName,
    this.onCancel,
    this.onAccept,
    this.cancelButtonColor,
    this.cancelTextColor,
    this.acceptButtonColor,
    this.acceptTextColor,
    this.backAllowedButton,
    this.showCancleButton,
    this.svgImagePath,
    this.svgImageColor,
    this.barrierDismissable,
    this.isAcceptContainesPush,
    this.titleColor,
    this.titleWeight,
  });
  final String? cancelButtonName;
  final String? acceptButtonName;
  final VoidCallback? onCancel;
  final String? svgImagePath;
  final Color? svgImageColor;
  final Future<dynamic> Function()? onAccept;
  final String title;
  final Widget content;
  final Color? cancelButtonColor;
  final Color? cancelTextColor;
  final Color? acceptButtonColor;
  final Color? acceptTextColor;
  final bool? backAllowedButton;
  final bool? showCancleButton;
  final bool? barrierDismissable;
  final bool? isAcceptContainesPush;
  final bool showAcceptButton;
  final Color? titleColor;
  final FontWeight? titleWeight;

  @override
  Widget build(BuildContext context) {
    ///This backAllowedButton will help us to prevent back presses from sensitive dialoges
    return Stack(
      children: [
        //Make dialoge box's background lighter black
        GestureDetector(
          onTap: () {
            if (barrierDismissable ?? false) {
              Navigator.pop(context);
            }
          },
          child: Container(
            color: Colors.black.withValues(alpha: 0.14),
          ),
        ),
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (backAllowedButton == false) {
              return Future.value(false);
            }
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop();
            });
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AlertDialog(
                backgroundColor: context.color.secondaryColor,
                actionsPadding: showAcceptButton
                    ? const EdgeInsets.symmetric(vertical: 8)
                    : EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Column(
                  children: [
                    if (svgImagePath != null) ...[
                      CircleAvatar(
                        radius: 186 / 2,
                        backgroundColor:
                            context.color.tertiaryColor.withValues(alpha: 0.1),
                        child: SizedBox(
                          child: UiUtils.getSvg(
                            svgImagePath!,
                            color: svgImageColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                    CustomText(
                      title.firstUpperCase(),
                      color: titleColor ?? context.color.textColorDark,
                      fontWeight: titleWeight ?? FontWeight.w400,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: content,
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showCancleButton ?? true) ...[
                        button(
                          context,
                          constraints: constraints,
                          buttonColor:
                              cancelButtonColor ?? context.color.primaryColor,
                          buttonName: cancelButtonName ??
                              UiUtils.translate(context, 'cancelBtnLbl'),
                          textColor:
                              cancelTextColor ?? context.color.textColorDark,
                          onTap: () {
                            onCancel?.call();
                            Navigator.pop(context, false);
                          },
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                      Builder(
                        builder: (context) {
                          if (showCancleButton == false && showAcceptButton) {
                            return Center(
                              child: SizedBox(
                                width: context.screenWidth / 2,
                                child: button(
                                  context,
                                  constraints: constraints,
                                  buttonColor: acceptButtonColor ??
                                      context.color.tertiaryColor,
                                  buttonName: acceptButtonName ??
                                      UiUtils.translate(context, 'ok'),
                                  textColor: acceptTextColor ??
                                      context.color.textColorDark,
                                  onTap: () async {
                                    await onAccept?.call();

                                    if (isAcceptContainesPush == false ||
                                        isAcceptContainesPush == null) {
                                      Future.delayed(
                                        Duration.zero,
                                        () {
                                          Navigator.pop(context, true);
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          }
                          if (showAcceptButton) {
                            return button(
                              context,
                              constraints: constraints,
                              buttonColor: acceptButtonColor ??
                                  context.color.tertiaryColor,
                              buttonName: acceptButtonName ??
                                  UiUtils.translate(context, 'ok'),
                              textColor: acceptTextColor ??
                                  const Color.fromARGB(255, 255, 255, 255),
                              onTap: () async {
                                if (!context.mounted) return;
                                await onAccept?.call();
                                if (isAcceptContainesPush == false ||
                                    isAcceptContainesPush == null) {
                                  Future.delayed(
                                    Duration.zero,
                                    () {
                                      Navigator.pop(context, true);
                                    },
                                  );
                                }
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Color makeColorDark(Color color) {
    final color0 = color;

    final red = color0.r - 10;
    final green = color0.g - 10;
    final blue = color0.b - 10;

    return Color.fromARGB(
      color0.a.toInt(),
      red.clamp(0, 255).toInt(),
      green.clamp(0, 255).toInt(),
      blue.clamp(0, 255).toInt(),
    );
  }

  Widget button(
    BuildContext context, {
    required BoxConstraints constraints,
    required Color buttonColor,
    required String buttonName,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: constraints.maxWidth / 3.1,
      child: MaterialButton(
        elevation: 0,
        height: 39.rh(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: context.color.borderColor),
        ),
        color: buttonColor,
        // minWidth: (constraints.maxWidth / 2) - 10,
        onPressed: onTap,
        child: CustomText(
          buttonName,
          color: textColor,
        ),
      ),
    );
  }
}

///This dialoge box will blur background of screen
///This is normaly a screen which blurs its background we don't show builtin dialog box here instead we push to new route and show container in middle of screen
class BlurredDialogBuilderBox extends StatelessWidget implements BlurDialoge {
  const BlurredDialogBuilderBox({
    required this.title,
    required this.contentBuilder,
    super.key,
    this.cancelButtonName,
    this.acceptButtonName,
    this.onCancel,
    this.onAccept,
    this.cancelButtonColor,
    this.cancelTextColor,
    this.acceptButtonColor,
    this.acceptTextColor,
    this.backAllowedButton,
    this.showCancleButton,
    this.svgImagePath,
    this.svgImageColor,
    this.isAcceptContainesPush,
  });
  final String? cancelButtonName;
  final String? acceptButtonName;
  final VoidCallback? onCancel;
  final String? svgImagePath;
  final Color? svgImageColor;
  final Future<dynamic> Function()? onAccept;
  final String title;
  final Widget? Function(BuildContext context, BoxConstraints constrains)
      contentBuilder;
  final Color? cancelButtonColor;
  final Color? cancelTextColor;
  final Color? acceptButtonColor;
  final Color? acceptTextColor;
  final bool? backAllowedButton;
  final bool? showCancleButton;
  final bool? isAcceptContainesPush;

  @override
  Widget build(BuildContext context) {
    ///This backAllowedButton will help us to prevent back presses from sensitive dialoges
    return Stack(
      children: [
        //Make dialog box's background lighter black
        Container(
          color: Colors.black.withValues(alpha: 0.14),
        ),
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (backAllowedButton == false) {
              return Future.value(false);
            }
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop();
            });
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AlertDialog(
                backgroundColor: context.color.secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Column(
                  children: [
                    if (svgImagePath != null) ...[
                      CircleAvatar(
                        radius: 98 / 2,
                        backgroundColor:
                            context.color.tertiaryColor.withValues(alpha: 0.1),
                        child: SizedBox(
                          width: 87 / 2,
                          height: 87 / 2,
                          child: UiUtils.getSvg(
                            svgImagePath!,
                            color: svgImageColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                    CustomText(
                      title.firstUpperCase(),
                      textAlign: TextAlign.center,
                      fontSize: context.font.extraLarge,
                    ),
                  ],
                ),
                content: contentBuilder.call(context, constraints),
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  Row(
                    children: [
                      if (showCancleButton ?? true) ...[
                        button(
                          context,
                          constraints: constraints,
                          buttonColor: cancelButtonColor ??
                              context.color.tertiaryColor
                                  .withValues(alpha: .10),
                          buttonName: cancelButtonName ??
                              UiUtils.translate(context, 'cancelBtnLbl'),
                          textColor:
                              cancelTextColor ?? context.color.textColorDark,
                          onTap: () {
                            onCancel?.call();
                            Navigator.pop(context, false);
                          },
                        ),
                      ],
                      Builder(
                        builder: (context) {
                          if (showCancleButton == false) {
                            return Center(
                              child: SizedBox(
                                width: context.screenWidth / 2,
                                child: button(
                                  context,
                                  constraints: constraints,
                                  buttonColor: acceptButtonColor ??
                                      context.color.tertiaryColor,
                                  buttonName: acceptButtonName ??
                                      UiUtils.translate(context, 'ok'),
                                  textColor: acceptTextColor ??
                                      context.color.textColorDark,
                                  onTap: () async {
                                    await onAccept?.call();

                                    if (isAcceptContainesPush == false ||
                                        isAcceptContainesPush == null) {
                                      Future.delayed(
                                        Duration.zero,
                                        () {
                                          Navigator.pop(context, true);
                                        },
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          }
                          return button(
                            context,
                            constraints: constraints,
                            buttonColor: acceptButtonColor ??
                                context.color.tertiaryColor,
                            buttonName: acceptButtonName ??
                                UiUtils.translate(context, 'ok'),
                            textColor: acceptTextColor ??
                                const Color.fromARGB(255, 255, 255, 255),
                            onTap: () async {
                              await onAccept?.call();
                              if (isAcceptContainesPush == false ||
                                  isAcceptContainesPush == null) {
                                Future.delayed(
                                  Duration.zero,
                                  () {
                                    Navigator.pop(context, true);
                                  },
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget button(
    BuildContext context, {
    required BoxConstraints constraints,
    required Color buttonColor,
    required String buttonName,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: constraints.maxWidth / 3.2,
      child: MaterialButton(
        elevation: 0,
        height: 39.rh(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: buttonColor,
        onPressed: onTap,
        child: CustomText(
          buttonName,
          color: textColor,
        ),
      ),
    );
  }
}

class BlurredSubscriptionDialogBox extends StatelessWidget
    implements BlurDialoge {
  const BlurredSubscriptionDialogBox({
    required this.packageType,
    super.key,
    this.onCancel,
    this.backAllowedButton,
    this.barrierDismissable,
    this.isAcceptContainesPush,
  });
  final SubscriptionPackageType packageType;
  final VoidCallback? onCancel;
  final bool? backAllowedButton;
  final bool? barrierDismissable;
  final bool? isAcceptContainesPush;

  @override
  Widget build(BuildContext context) {
    ///This backAllowedButton will help us to prevent back presses from sensitive dialoges
    return Stack(
      children: [
        //Make dialoge box's background lighter black
        GestureDetector(
          onTap: () {
            if (barrierDismissable ?? false) {
              Navigator.pop(context);
            }
          },
          child: Container(color: Colors.transparent),
        ),
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (backAllowedButton == false) {
              return Future.value(false);
            }
            Future.delayed(Duration.zero, () {
              Navigator.of(context).pop();
            });
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return AlertDialog(
                elevation: 0,
                titlePadding:
                    const EdgeInsets.only(top: 18, left: 24, right: 24),
                contentPadding: EdgeInsets.zero,
                backgroundColor: context.color.brightness == Brightness.light
                    ? Color.lerp(
                        context.color.tertiaryColor,
                        Colors.white,
                        0.85,
                      )
                    : Color.lerp(
                        context.color.tertiaryColor,
                        Colors.black,
                        0.85,
                      ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      'subscribeNow'.translate(context),
                      fontSize: context.font.larger,
                      fontWeight: FontWeight.w700,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 24,
                        width: 24,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: context.color.borderColor),
                        ),
                        child: Icon(
                          Icons.close,
                          color: context.color.inverseSurface,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width * 0.6,
                      ),
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.color.secondaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: UiUtils.getSvg(
                                AppIcons.premium,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 14,
                          ),
                          Flexible(
                            flex: 3,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  packageType.title.translate(context),
                                  fontSize: context.font.large,
                                  fontWeight: FontWeight.w700,
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                CustomText(
                                  packageType.description.translate(context),
                                  fontSize: context.font.small,
                                  color: context.color.textColorDark
                                      .withValues(alpha: 0.5),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  Builder(
                    builder: (context) {
                      return Center(
                        child: SizedBox(
                          child: button(
                            context,
                            constraints: constraints,
                            buttonColor: context.color.tertiaryColor,
                            buttonName: UiUtils.translate(context, 'viewPlans'),
                            onTap: () async {
                              final apiKeyState =
                                  context.read<GetApiKeysCubit>().state;
                              if (apiKeyState is GetApiKeysFail) {
                                final errorMessage = (context
                                        .read<GetApiKeysCubit>()
                                        .state as GetApiKeysFail)
                                    .error
                                    .toString();
                                await HelperUtils.showSnackBarMessage(
                                  context,
                                  errorMessage,
                                );
                                Navigator.pop(context);
                                return;
                              }
                              await Navigator.popAndPushNamed(
                                context,
                                Routes.subscriptionPackageListRoute,
                                arguments: {
                                  'from': 'home',
                                  'isBankTransferEnabled': (context
                                              .read<GetApiKeysCubit>()
                                              .state as GetApiKeysSuccess)
                                          .bankTransferStatus ==
                                      '1',
                                },
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Color makeColorDark(Color color) {
    final color0 = color;

    final red = color0.r - 10;
    final green = color0.g - 10;
    final blue = color0.b - 10;

    return Color.fromARGB(
      color0.a.toInt(),
      red.clamp(0, 255).toInt(),
      green.clamp(0, 255).toInt(),
      blue.clamp(0, 255).toInt(),
    );
  }

  Widget button(
    BuildContext context, {
    required BoxConstraints constraints,
    required Color buttonColor,
    required String buttonName,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MaterialButton(
        elevation: 0,
        height: 45.rh(context),
        minWidth: constraints.maxWidth * 0.7,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: context.color.borderColor),
        ),
        color: buttonColor,
        // minWidth: (constraints.maxWidth / 2) - 10,

        onPressed: onTap,
        child: CustomText(
          buttonName,
          fontSize: context.font.larger,
          color: context.color.buttonColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class EmptyDialogBox extends StatelessWidget with BlurDialoge {
  const EmptyDialogBox({
    required this.child,
    super.key,
    this.barrierDismisable,
  });
  final Widget child;
  final bool? barrierDismisable;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (barrierDismisable ?? true) Navigator.pop(context);
            },
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}

enum SubscriptionPackageType {
  propertyList(
    'property_list',
    title: 'propertyListTitle',
    description: 'propertyListDescription',
  ),
  propertyFeature(
    'property_feature',
    title: 'propertyFeatureTitle',
    description: 'propertyFeatureDescription',
  ),
  projectList(
    'project_list',
    title: 'projectListTitle',
    description: 'projectListDescription',
  ),
  projectFeature(
    'project_feature',
    title: 'projectFeatureTitle',
    description: 'projectFeatureDescription',
  ),
  mortgageCalculatorDetail(
    'mortgage_calculator_detail',
    title: 'mortgageCalculatorDetailTitle',
    description: 'mortgageCalculatorDetailDescription',
  ),
  premiumProperties(
    'premium_properties',
    title: 'premiumPropertiesTitle',
    description: 'premiumPropertiesDescription',
  ),
  projectAccess(
    'project_access',
    title: 'projectAccessTitle',
    description: 'projectAccessDescription',
  ),
  ;

  const SubscriptionPackageType(
    this.value, {
    required this.title,
    required this.description,
  });

  final String value;
  final String title;
  final String description;
}
