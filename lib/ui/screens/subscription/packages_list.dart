import 'dart:developer';

import 'package:ebroker/data/cubits/subscription/assign_free_package.dart';
import 'package:ebroker/data/cubits/subscription/assign_package.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/subscription/widget/my_packages_tile.dart';
import 'package:ebroker/ui/screens/subscription/widget/package_tile.dart';
import 'package:ebroker/utils/AdMob/bannerAdLoadWidget.dart';
import 'package:ebroker/utils/AdMob/interstitialAdManager.dart';
import 'package:ebroker/utils/payment/in_app_purchase/inAppPurchaseManager.dart';
import 'package:ebroker/utils/payment/lib/payment.dart';
import 'package:ebroker/utils/payment/lib/payment_service.dart';
import 'package:flutter/material.dart';

class SubscriptionPackageListScreen extends StatefulWidget {
  const SubscriptionPackageListScreen({super.key, this.from});
  final String? from;

  static Route<dynamic> route(RouteSettings settings) {
    final arguments = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => GetSubsctiptionPackageLimitsCubit(),
            ),
            BlocProvider(
              create: (context) => AssignFreePackageCubit(),
            ),
            BlocProvider(
              create: (context) => AssignInAppPackageCubit(),
            ),
          ],
          child: SubscriptionPackageListScreen(
            from: arguments?['from']?.toString() ?? '',
          ),
        );
      },
    );
  }

  @override
  State<SubscriptionPackageListScreen> createState() =>
      _SubscriptionPackageListScreenState();
}

class _SubscriptionPackageListScreenState
    extends State<SubscriptionPackageListScreen>
    with SingleTickerProviderStateMixin {
  InterstitialAdManager interstitialAdManager = InterstitialAdManager();
  InAppPurchaseManager inAppPurchase = InAppPurchaseManager();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  @override
  void initState() {
    // Initialize tab controller with 2 tabs
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 1;

    _scrollController.addListener(() {
      if (_scrollController.isEndReached()) {
        if (context.read<FetchSubscriptionPackagesCubit>().hasMore()) {
          context.read<FetchSubscriptionPackagesCubit>().fetchMorePackages();
        }
      }
    });

    context.read<FetchSubscriptionPackagesCubit>().fetchPackages();
    interstitialAdManager.load();
    InAppPurchaseManager.getPendings();
    inAppPurchase.listenIAP(context);

    super.initState();
  }

  @override
  void dispose() {
    // Dispose the tab controller
    _tabController.dispose();
    super.dispose();
  }

  dynamic ifServiceUnlimited(text, {remining}) {
    if (text == 'unlimited') {
      return UiUtils.translate(context, 'unlimited');
    }
    if (text == 'not_available') {
      return '';
    }
    if (remining != null) {
      return '';
    }

    return text;
  }

  bool isUnlimited(int text, {remining}) {
    if (text == 0) {
      return true;
    }
    if (remining != null) {
      return false;
    }

    return false;
  }

  Future<void> _onTapSubscribe(
    SubscriptionPackageModel subscriptionPackage,
  ) async {
    log('######## ${AppSettings.enabledPaymentGatway}----${AppSettings.razorpayKey}');

    if (subscriptionPackage.price == 0) {
      await context.read<AssignFreePackageCubit>().assign(
            subscriptionPackage.id,
          );
      return;
    }
    if (Platform.isIOS) {
      await inAppPurchase.buy(
        subscriptionPackage.iosProductId,
        subscriptionPackage.id.toString(),
      );
      return;
    }
    if (isPaymentGatewayOpen == false) {
      final paymentService = PaymentService()
        ..targetGatwayKey = AppSettings.enabledPaymentGatway
        ..attachedGatways(gatways)
        ..setContext(context)
        ..setPackage(subscriptionPackage);
      await paymentService.pay();
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: UiUtils.buildAppBar(
        context,
        showBackButton: true,
        title: UiUtils.translate(context, 'subscriptionPlan'),
        bottomHeight: 50,
        bottom: [
          TabBar(
            controller: _tabController,
            indicatorColor: context.color.tertiaryColor,
            labelColor: context.color.tertiaryColor,
            unselectedLabelColor: context.color.textColorDark,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            tabs: [
              Tab(text: UiUtils.translate(context, 'myPlans')),
              Tab(text: UiUtils.translate(context, 'allPlans')),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const BottomAppBar(
        child: BannerAdWidget(bannerSize: AdSize.banner),
      ),
      body: RefreshIndicator(
        backgroundColor: context.color.primaryColor,
        color: context.color.tertiaryColor,
        onRefresh: () async {
          await context.read<FetchSubscriptionPackagesCubit>().fetchPackages();
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await interstitialAdManager.show();
            Future.delayed(
              Duration.zero,
              () {
                Navigator.pop(context);
              },
            );
          },
          child: MultiBlocListener(
            listeners: [
              BlocListener<AssignInAppPackageCubit, AssignInAppPackageState>(
                listener: (context, state) {
                  if (state is AssignInAppPackageSuccess) {
                    context.read<FetchSystemSettingsCubit>().fetchSettings(
                          isAnonymous: false,
                          forceRefresh: true,
                        );
                    HelperUtils.showSnackBarMessage(
                      context,
                      'Package Assigned',
                    );
                  }
                },
              ),
            ],
            child: Builder(
              builder: (context) {
                return BlocListener<AssignFreePackageCubit,
                    AssignFreePackageState>(
                  listener: (context, state) {
                    if (state is AssignFreePackageInProgress) {
                      unawaited(Widgets.showLoader(context));
                    }

                    if (state is AssignFreePackageSuccess) {
                      Widgets.hideLoder(context);
                      context
                          .read<FetchSubscriptionPackagesCubit>()
                          .fetchPackages();
                      context.read<FetchSystemSettingsCubit>().fetchSettings(
                            isAnonymous: false,
                            forceRefresh: true,
                          );

                      HelperUtils.showSnackBarMessage(
                        context,
                        'Free package is assigned',
                      );
                    }

                    if (state is AssignFreePackageFail) {
                      Widgets.hideLoder(context);

                      HelperUtils.showSnackBarMessage(
                        context,
                        'Failed to assign free package',
                      );
                    }
                  },
                  child: BlocBuilder<FetchSubscriptionPackagesCubit,
                      FetchSubscriptionPackagesState>(
                    builder: (context, state) {
                      if (state is FetchSubscriptionPackagesInProgress) {
                        return ListView.builder(
                          itemCount: 10,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                              child: CustomShimmer(
                                height: 160,
                              ),
                            );
                          },
                        );
                      }
                      if (state is FetchSubscriptionPackagesFailure) {
                        if (state.errorMessage is NoInternetConnectionError) {
                          return NoInternet(
                            onRetry: () {
                              context
                                  .read<FetchSubscriptionPackagesCubit>()
                                  .fetchPackages();
                            },
                          );
                        }

                        return const SomethingWentWrong();
                      }
                      if (state is FetchSubscriptionPackagesSuccess) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            // Current Plan Tab
                            _buildCurrentPlanTab(state),

                            // Other Plans Tab
                            _buildOtherPlansTab(state),
                          ],
                        );
                      }

                      return Container();
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlanTab(FetchSubscriptionPackagesSuccess state) {
    // Find and display only the active package
    final currentPackage = state.packageResponseModel.activePackage;

    return currentPackage.isNotEmpty
        ? ListView.builder(
            itemCount: currentPackage.length,
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              return CurrentPackageTileCard(
                package: currentPackage[index],
                allFeatures: state.packageResponseModel.allFeature,
              );
            },
          )
        : const Center(
            child: NoDataFound(),
          );
  }

  Widget _buildOtherPlansTab(FetchSubscriptionPackagesSuccess state) {
    // Filter out the active package
    final otherPackages = state.packageResponseModel.subscriptionPackage;

    return SingleChildScrollView(
      physics: Constant.scrollPhysics,
      child: otherPackages.isNotEmpty
          ? Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: otherPackages.length,
                  itemBuilder: (context, index) {
                    final subscriptionPackage = otherPackages[index];
                    return SubscriptionPackageTile(
                      package: subscriptionPackage,
                      packageFeatures: state.packageResponseModel.allFeature,
                      onTap: () {
                        _onTapSubscribe(subscriptionPackage);
                      },
                    );
                  },
                ),
                if (state.isLoadingMore) UiUtils.progress(),
                if (state.hasError) const CustomText('Something went wrong'),
              ],
            )
          : const Center(
              child: NoDataFound(),
            ),
    );
  }
}
