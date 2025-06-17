// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
import 'dart:developer';

import 'package:ebroker/data/cubits/Interested/get_interested_user_cubit.dart';
import 'package:ebroker/data/cubits/Report/property_report_cubit.dart';
import 'package:ebroker/data/cubits/Utility/mortgage_calculator_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/data/cubits/property/Interest/change_interest_in_property_cubit.dart';
import 'package:ebroker/data/cubits/property/change_property_status_cubit.dart';
import 'package:ebroker/data/cubits/property/delete_property_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_similar_properties_cubit.dart';
import 'package:ebroker/data/cubits/property/update_property_status.dart';
import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat_optimisation/chat_screen_new.dart';
import 'package:ebroker/ui/screens/home/widgets/property_card_big.dart';
import 'package:ebroker/ui/screens/proprties/Property%20tab/sell_rent_screen.dart';
import 'package:ebroker/ui/screens/proprties/widgets/agent_profile.dart';
import 'package:ebroker/ui/screens/proprties/widgets/download_doc.dart';
import 'package:ebroker/ui/screens/proprties/widgets/google_map_screen.dart';
import 'package:ebroker/ui/screens/proprties/widgets/interested_users.dart';
import 'package:ebroker/ui/screens/proprties/widgets/mortgage_calculator.dart';
import 'package:ebroker/ui/screens/proprties/widgets/outdoor_facilities.dart';
import 'package:ebroker/ui/screens/proprties/widgets/report_property_widget.dart';
import 'package:ebroker/ui/screens/widgets/all_gallary_image.dart';
import 'package:ebroker/ui/screens/widgets/like_button_widget.dart';
import 'package:ebroker/ui/screens/widgets/panaroma_image_view.dart';
import 'package:ebroker/ui/screens/widgets/read_more_text.dart';
import 'package:ebroker/ui/screens/widgets/video_view_screen.dart';
import 'package:ebroker/utils/admob/interstitial_ad_manager.dart';
import 'package:ebroker/utils/network/network_availability.dart';
import 'package:ebroker/utils/string_extenstion.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart' as urllauncher;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PropertyDetails extends StatefulWidget {
  final PropertyModel? property;

  final bool? fromMyProperty;
  final bool? fromCompleteEnquiry;
  final bool? fromPropertyAddSuccess;

  const PropertyDetails({
    required this.property,
    super.key,
    this.fromPropertyAddSuccess,
    this.fromMyProperty,
    this.fromCompleteEnquiry,
  });

  @override
  PropertyDetailsState createState() => PropertyDetailsState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    try {
      final arguments = routeSettings.arguments as Map?;
      return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ChangeInterestInPropertyCubit(),
            ),
            BlocProvider(
              create: (context) => UpdatePropertyStatusCubit(),
            ),
            BlocProvider(
              create: (context) => DeletePropertyCubit(),
            ),
            BlocProvider(
              create: (context) => PropertyReportCubit(),
            ),
            BlocProvider(
              create: (context) => GetInterestedUserCubit(),
            ),
            BlocProvider(
              create: (context) => FetchAgentsPropertyCubit(),
            ),
            BlocProvider(
              create: (context) => FetchSimilarPropertiesCubit(),
            ),
          ],
          child: PropertyDetails(
            property:
                arguments?['propertyData'] as PropertyModel? ?? PropertyModel(),
            fromMyProperty: arguments?['fromMyProperty'] as bool? ?? false,
            fromCompleteEnquiry:
                arguments?['fromCompleteEnquiry'] as bool? ?? false,
            fromPropertyAddSuccess: arguments?['fromSuccess'] as bool? ?? false,
          ),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}

class PropertyDetailsState extends State<PropertyDetails>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  FlickManager? flickManager;
  ValueNotifier<bool> shouldShowSubscriptionOverlay = ValueNotifier(false);

  // late Property propertyData;
  int selectedIndexExpansionTileForYears = -1;
  int selectedIndexExpansionTileForMonths = -1;
  bool favoriteInProgress = false;
  bool isPlayingYoutubeVideo = false;
  bool fromMyProperty = false; //get its value from Widget
  bool fromCompleteEnquiry = false; //get its value from Widget
  List<dynamic> promotedProeprtiesIds = [];
  bool toggleEnqButton = false;
  PropertyModel? property;
  bool isPromoted = false;
  bool showGoogleMap = false;
  bool isEnquiryFromChat = false;
  BannerAd? _bannerAd;
  bool isVerified = false;
  ValueNotifier<bool> isEnabled = ValueNotifier(false);
  bool isApproved = false;
  bool isProfileCompleted = HiveUtils.getUserDetails().email != '' &&
      HiveUtils.getUserDetails().mobile != '' &&
      HiveUtils.getUserDetails().name != '' &&
      HiveUtils.getUserDetails().address != '' &&
      HiveUtils.getUserDetails().profile != '';
  @override
  bool get wantKeepAlive => true;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  List<Gallery>? gallary;
  String youtubeVideoThumbnail = '';
  late bool? isLoaded;
  InterstitialAdManager interstitialAdManager = InterstitialAdManager();
  bool isPremiumProperty = true;
  bool isPremiumUser = false;
  bool isReported = false;

  @override
  void initState() {
    super.initState();
    isEnabled.value = widget.property?.status.toString() == '1';
    isApproved = widget.property?.requestStatus.toString() == 'approved';
    isVerified = widget.property?.isVerified ?? false;
    isPremiumProperty =
        widget.property?.allPropData['is_premium'] as bool? ?? false;

    isReported = widget.property?.allPropData?['is_reported'] as bool? ?? false;
    if (widget.property?.addedBy.toString() != HiveUtils.getUserId()) {
      loadAd();
      interstitialAdManager.load();
    }
    // customListenerForConstant();
    //add title image along with gallery images
    context.read<FetchOutdoorFacilityListCubit>().fetch();
    if (widget.property?.addedBy.toString() == HiveUtils.getUserId()) {
      try {
        context.read<GetInterestedUserCubit>().fetch(
              '${widget.property?.id}',
            );
      } catch (e) {
        Widgets.hideLoder(context);
      }
    }
    if (HiveUtils.isGuest() == false) {
      context.read<GetChatListCubit>().fetch(forceRefresh: true);
    }
    context.read<FetchSimilarPropertiesCubit>().fetchSimilarProperty(
          propertyId: widget.property!.id!,
        );

    Future.delayed(
      const Duration(seconds: 3),
      () {
        showGoogleMap = true;
        if (mounted) setState(() {});
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      gallary = List.from(widget.property!.gallery!);
      if (widget.property?.video != '' && widget.property?.video != null) {
        injectVideoInGallery();
        setState(() {});
      }
    });

    property = widget.property;
    setData();

    if (widget.property?.video != '' &&
        widget.property?.video != null &&
        !HelperUtils.isYoutubeVideo(widget.property?.video ?? '')) {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.networkUrl(
          Uri.parse(property!.video!),
        ),
      );
      flickManager?.onVideoEnd = () {};
    }

    if (widget.property?.video != '' &&
        widget.property?.video != null &&
        HelperUtils.isYoutubeVideo(widget.property?.video ?? '')) {
      final videoId = YoutubePlayer.convertUrlToId(property!.video!);
      final thumbnail = YoutubePlayer.getThumbnail(videoId: videoId!);
      youtubeVideoThumbnail = thumbnail;
      setState(() {});
    }
    context.read<FetchPropertyReportReasonsListCubit>().fetch();
  }

  Future<void> onBackPress({required bool isFromAppBar}) async {
    if (widget.property?.addedBy.toString() != HiveUtils.getUserId()) {
      await interstitialAdManager.show();
    }
    context.read<MortgageCalculatorCubit>().emptyMortgageCalculatorData();
    if (widget.property?.addedBy.toString() == HiveUtils.getUserId()) {
      await context.read<FetchMyPropertiesCubit>().fetchMyProperties(
            type: '',
            status: '',
          );
    }
    setState(() {
      showGoogleMap = false;
    });
    if (!isFromAppBar) {
      Future.delayed(Duration.zero, () {
        Navigator.pop(context);
      });
    }
  }

  Future<void> loadAd() async {
    _bannerAd = BannerAd(
      adUnitId: Constant.admobBannerAndroid,
      request: const AdRequest(),
      size: AdSize.largeBanner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    );
    await _bannerAd!.load();
  }

  void setData() {
    fromMyProperty = widget.fromMyProperty!;
    fromCompleteEnquiry = widget.fromCompleteEnquiry!;
  }

  late final CameraPosition _kInitialPlace = CameraPosition(
    target: LatLng(
      double.parse(
        property?.latitude ?? '0',
      ),
      double.parse(
        property?.longitude ?? '0',
      ),
    ),
    zoom: 14.4746,
  );

  @override
  void dispose() {
    _controller.future.then((value) => value.dispose());

    flickManager?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void injectVideoInGallery() {
    ///This will inject video in image list just like another platforms
    if ((gallary?.length ?? 0) < 2) {
      if (widget.property?.video != null && widget.property?.video != '') {
        gallary?.add(
          Gallery(
            id: 99999999999,
            image: property!.video ?? '',
            imageUrl: '',
            isVideo: true,
          ),
        );
      }
    } else {
      gallary?.insert(
        0,
        Gallery(
          id: 99999999999,
          image: property!.video!,
          imageUrl: '',
          isVideo: true,
        ),
      );
    }
    setState(() {});
  }

  String? _statusFilter(String value) {
    if (value == 'Sell' || value == 'sell') {
      return 'sold'.translate(context);
    }
    if (value == 'Rent' || value == 'rent') {
      return 'Rented'.translate(context);
    }

    return null;
  }

  int? _getStatus(type) {
    int? value;
    if (type == 'Sell' || type == 'sell') {
      value = 2;
    } else if (type == 'Rent' || type == 'rent') {
      value = 3;
    } else if (type == 'Rented' || type == 'rented') {
      value = 1;
    }
    return value;
  }

  bool hasDocuments() {
    return widget.property!.documents!.isNotEmpty;
  }

//main build
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var rentPrice = property!.price!.priceFormat(
      enabled: Constant.isNumberWithSuffix == true,
      context: context,
    );

    if (property?.rentduration != '' && property?.rentduration != null) {
      rentPrice =
          '$rentPrice / ${(property!.rentduration ?? '').translate(context)}';
    }
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await onBackPress(isFromAppBar: false);
        },
        child: BlocListener<GetSubsctiptionPackageLimitsCubit,
            GetSubscriptionPackageLimitsState>(
          listener: (context, state) {
            if (state is GetSubscriptionPackageLimitsSuccess) {
              isPremiumUser = state.hasSubscription;
              setState(() {});
            }
          },
          child: Stack(
            children: [
              Scaffold(
                appBar: UiUtils.buildAppBar(
                  context,
                  showBackButton: true,
                  onbackpress: () async {
                    await onBackPress(isFromAppBar: true);
                  },
                  actions: [
                    const Spacer(),
                    if (!HiveUtils.isGuest()) ...[
                      if (!(int.parse(HiveUtils.getUserId() ?? '0') ==
                          property?.addedBy))
                        Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: 12,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              HelperUtils.share(
                                context,
                                property!.id!,
                                property?.slugId ?? '',
                              );
                            },
                            child: UiUtils.getSvg(
                              AppIcons.shareIcon,
                            ),
                          ),
                        ),
                    ],
                    if (property?.addedBy.toString() == HiveUtils.getUserId())
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'share') {
                            await HelperUtils.share(
                              context,
                              property!.id!,
                              property?.slugId ?? '',
                            );
                          }
                          if (value == 'interestedUsers') {
                            final interestedUserCubitReference =
                                context.read<GetInterestedUserCubit>();
                            await showModalBottomSheet<dynamic>(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20).copyWith(
                                  bottomLeft: Radius.zero,
                                  bottomRight: Radius.zero,
                                ),
                              ),
                              backgroundColor: context.color.secondaryColor,
                              constraints: BoxConstraints(
                                minWidth: double.infinity,
                                maxHeight: context.screenHeight * 0.7,
                                minHeight: context.screenHeight * 0.3,
                              ),
                              builder: (context) {
                                return InterestedUserListWidget(
                                  totalCount:
                                      '${widget.property?.totalInterestedUsers}',
                                  interestedUserCubitReference:
                                      interestedUserCubitReference,
                                );
                              },
                            );
                            return;
                          }
                          if (value == 'markAsSold') {
                            final action = await UiUtils.showBlurredDialoge(
                              context,
                              dialog: BlurredDialogBuilderBox(
                                title:
                                    'changePropertyStatus'.translate(context),
                                acceptButtonName: 'change'.translate(context),
                                cancelTextColor: context.color.tertiaryColor,
                                contentBuilder: (context, s) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: context.color.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: context.color.borderColor,
                                          ),
                                        ),
                                        width: s.maxWidth,
                                        height: 50,
                                        child: Center(
                                          child: CustomText(
                                            property!.properyType!
                                                .translate(context),
                                            color: context.color.inverseSurface,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: CustomText(
                                          'to'.translate(context),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Container(
                                        width: s.maxWidth,
                                        decoration: BoxDecoration(
                                          color: context.color.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: context.color.borderColor,
                                          ),
                                        ),
                                        height: 50,
                                        child: Center(
                                          child: CustomText(
                                            _statusFilter(
                                                  property!.properyType!,
                                                ) ??
                                                '',
                                            color: context.color.inverseSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                            if (action == true) {
                              Future.delayed(Duration.zero, () {
                                context
                                    .read<UpdatePropertyStatusCubit>()
                                    .update(
                                      propertyId: property!.id,
                                      status: _getStatus(property!.properyType),
                                    );
                              });
                            }
                          }
                        },
                        color: context.color.secondaryColor,
                        itemBuilder: (BuildContext context) {
                          return [
                            buildPopupMenItem(
                              context: context,
                              title: 'share',
                              icon: AppIcons.shareIcon,
                              index: 0,
                            ),
                            buildPopupMenItem(
                              context: context,
                              title: 'interestedUsers',
                              icon: AppIcons.interestedUsers,
                              index: 1,
                            ),
                            if (property?.properyType != 'sold' &&
                                property?.properyType != 'rented')
                              buildPopupMenItem(
                                context: context,
                                title: 'markAsSold',
                                icon: AppIcons.changeStatus,
                                index: 2,
                              ),
                          ];
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.more_vert_rounded,
                            color: context.color.tertiaryColor,
                          ),
                        ),
                      ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
                backgroundColor: context.color.primaryColor,
                floatingActionButton: (property == null ||
                        property!.addedBy.toString() == HiveUtils.getUserId())
                    ? const SizedBox.shrink()
                    : Container(),
                bottomNavigationBar: isPlayingYoutubeVideo == false
                    ? BottomAppBar(
                        key: UniqueKey(),
                        padding: EdgeInsets.zero,
                        color: context.color.secondaryColor,
                        child: bottomNavBar(),
                      )
                    : null,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerFloat,
                body: BlocListener<DeletePropertyCubit, DeletePropertyState>(
                  listener: (context, state) {
                    if (state is DeletePropertyInProgress) {
                      Widgets.showLoader(context);
                    }

                    if (state is DeletePropertySuccess) {
                      Widgets.hideLoder(context);
                      Future.delayed(
                        const Duration(milliseconds: 1000),
                        () {
                          Navigator.pop(context, true);
                        },
                      );
                    }
                    if (state is DeletePropertyFailure) {
                      Widgets.showLoader(context);
                    }
                  },
                  child: SingleChildScrollView(
                    physics: Constant.scrollPhysics,
                    child: BlocListener<UpdatePropertyStatusCubit,
                        UpdatePropertyStatusState>(
                      listener: (context, state) {
                        if (state is UpdatePropertyStatusSuccess) {
                          Widgets.hideLoder(context);
                          Fluttertoast.showToast(
                            msg: 'statusUpdated'.translate(context),
                            backgroundColor: successMessageColor,
                            gravity: ToastGravity.TOP,
                            toastLength: Toast.LENGTH_LONG,
                          );

                          (cubitReference!).updateStatus(
                            property!.id!,
                            property!.properyType!,
                          );
                          setState(() {});
                        }
                        if (state is UpdatePropertyStatusFail) {
                          Widgets.hideLoder(context);
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isPlayingYoutubeVideo == false ? 20.0 : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),

                            if (!isPlayingYoutubeVideo)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      height: 227.rh(context),
                                      child: Stack(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              // google map doesn't allow blur so we hide it:)
                                              showGoogleMap = false;
                                              setState(() {});
                                              UiUtils.showFullScreenImage(
                                                context,
                                                provider: NetworkImage(
                                                  property!.titleImage!,
                                                ),
                                                then: () {
                                                  showGoogleMap = true;
                                                  setState(() {});
                                                },
                                              );
                                            },
                                            child: UiUtils.getImage(
                                              property!.titleImage!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 227.rh(context),
                                              showFullScreenImage: true,
                                            ),
                                          ),
                                          PositionedDirectional(
                                            top: 20,
                                            end: 20,
                                            child: LikeButtonWidget(
                                              propertyId: property!.id!,
                                              isFavourite:
                                                  property!.isFavourite!,
                                              onStateChange: (
                                                AddToFavoriteCubitState state,
                                              ) {
                                                if (state
                                                    is AddToFavoriteCubitInProgress) {
                                                  favoriteInProgress = true;
                                                  setState(
                                                    () {},
                                                  );
                                                } else {
                                                  favoriteInProgress = false;
                                                  setState(
                                                    () {},
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                          PositionedDirectional(
                                            bottom: 5,
                                            end: 18,
                                            child: Visibility(
                                              visible:
                                                  property?.threeDImage != '',
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    CupertinoPageRoute<dynamic>(
                                                      builder: (context) =>
                                                          PanaromaImageScreen(
                                                        imageUrl: property!
                                                            .threeDImage!,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: context
                                                        .color.secondaryColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  height: 40.rh(context),
                                                  width: 40.rw(context),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    child: UiUtils.getSvg(
                                                      AppIcons.v360Degree,
                                                      color: context
                                                          .color.tertiaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          advertisementLabel(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  if (property?.addedBy.toString() ==
                                      HiveUtils.getUserId()) ...[
                                    buildEnableDisableSwitch(),
                                  ],
                                  Row(
                                    children: [
                                      UiUtils.imageType(
                                        property?.category!.image ?? '',
                                        width: 18,
                                        height: 18,
                                        color: Constant.adaptThemeColorSvg
                                            ? context.color.tertiaryColor
                                            : null,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width: 158.rw(context),
                                        child: CustomText(
                                          property!.category!.category!,
                                          maxLines: 1,
                                          fontWeight: FontWeight.w400,
                                          fontSize: context.font.normal,
                                          color: context.color.textColorDark,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(3.5),
                                          color: context.color.tertiaryColor,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: Center(
                                            child: CustomText(
                                              property!.properyType
                                                  .toString()
                                                  .toLowerCase()
                                                  .translate(context),
                                              fontSize: context.font.small,
                                              color: context.color.buttonColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: CustomText(
                                          property!.title!.firstUpperCase(),
                                          fontWeight: FontWeight.w600,
                                          fontSize: context.font.larger,
                                          color: context.color.textColorDark,
                                        ),
                                      ),
                                      CustomText(
                                        property?.postCreated ?? '',
                                        color: context.color.textColorDark
                                            .withValues(alpha: 0.6),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 13),
                                  Row(
                                    children: [
                                      if (property!.properyType
                                              .toString()
                                              .toLowerCase() ==
                                          'rent') ...[
                                        CustomText(
                                          rentPrice,
                                          fontWeight: FontWeight.w700,
                                          fontSize: context.font.larger,
                                          color: context.color.tertiaryColor,
                                        ),
                                      ] else ...[
                                        CustomText(
                                          property!.price!.priceFormat(
                                            enabled:
                                                Constant.isNumberWithSuffix ==
                                                    true,
                                            context: context,
                                          ),
                                          fontWeight: FontWeight.w700,
                                          fontSize: context.font.larger,
                                          color: context.color.tertiaryColor,
                                        ),
                                      ],
                                      if (Constant.isNumberWithSuffix ==
                                          true) ...[
                                        if (property!.properyType
                                                .toString()
                                                .toLowerCase() !=
                                            'rent') ...[
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          CustomText(
                                            '(${property!.price!.priceFormat(context: context, enabled: false)})',
                                            fontWeight: FontWeight.w500,
                                            fontSize: context.font.larger,
                                            color: context.color.tertiaryColor,
                                          ),
                                        ],
                                      ],
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (widget.property?.properyType
                                          .toString()
                                          .toLowerCase() ==
                                      'sell') ...[
                                    _buildMortgageCalculatorContainer(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                  Container(
                                    padding: EdgeInsets.zero,
                                    width: double.infinity,
                                    child: GridView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      semanticChildCount:
                                          property?.parameters?.length ?? 0,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 2,
                                        // Increase the mainAxisExtent to accommodate multiple lines
                                        mainAxisExtent:
                                            80, // Changed from 51 to allow more vertical space
                                      ),
                                      itemCount:
                                          property?.parameters?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final parameter =
                                            property?.parameters![index];
                                        return Container(
                                          padding: EdgeInsets.zero,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start, // Align to top for better multi-line layout
                                            children: [
                                              Container(
                                                width: 40.rw(context),
                                                height: 40.rh(context),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: context
                                                      .color.tertiaryColor
                                                      .withValues(
                                                    alpha: 0.2,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                                child: SizedBox(
                                                  height: 30.rh(context),
                                                  width: 30.rw(context),
                                                  child: FittedBox(
                                                    child: UiUtils.imageType(
                                                      parameter?.image ?? '',
                                                      fit: BoxFit.cover,
                                                      color: Constant
                                                              .adaptThemeColorSvg
                                                          ? context.color
                                                              .tertiaryColor
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10.rw(context),
                                              ),
                                              Flexible(
                                                // Use Flexible instead of fixed SizedBox
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CustomText(
                                                      parameter?.name ?? '',
                                                      maxLines:
                                                          1, // Keep parameter name as single line
                                                      textAlign:
                                                          TextAlign.start,
                                                      fontSize:
                                                          context.font.small,
                                                      color: context
                                                          .color.textColorDark
                                                          .withValues(
                                                        alpha: 0.8,
                                                      ),
                                                    ),
                                                    if (parameter
                                                            ?.typeOfParameter ==
                                                        'file') ...{
                                                      InkWell(
                                                        onTap: () async {
                                                          await urllauncher
                                                              .launchUrl(
                                                            Uri.parse(
                                                              parameter!.value
                                                                      ?.toString() ??
                                                                  '',
                                                            ),
                                                            mode: LaunchMode
                                                                .externalApplication,
                                                          );
                                                        },
                                                        child: CustomText(
                                                          UiUtils.translate(
                                                            context,
                                                            'viewFile',
                                                          ),
                                                          showUnderline: true,
                                                          color: context.color
                                                              .tertiaryColor,
                                                        ),
                                                      ),
                                                    } else if (parameter?.value
                                                        is List) ...{
                                                      Flexible(
                                                        // Use Flexible instead of fixed Container
                                                        child: CustomText(
                                                          (parameter?.value
                                                                  as List)
                                                              .join(
                                                            ', ',
                                                          ), // Added space after comma
                                                          maxLines:
                                                              3, // Allow multiple lines
                                                        ),
                                                      ),
                                                    } else ...[
                                                      if (parameter
                                                              ?.typeOfParameter ==
                                                          'textarea') ...[
                                                        Flexible(
                                                          // Use Flexible to allow content to adjust
                                                          child: CustomText(
                                                            '${parameter?.value}',
                                                            maxLines:
                                                                3, // Allow up to 3 lines for textarea
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: context
                                                                .font.small,
                                                          ),
                                                        ),
                                                      ] else ...[
                                                        Flexible(
                                                          // Use Flexible instead of ConstrainedBox
                                                          child: CustomText(
                                                            '${parameter?.value}',
                                                            maxLines:
                                                                2, // Allow up to 2 lines for other content
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: context
                                                                .font.small,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  UiUtils.getDivider(),
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  CustomText(
                                    UiUtils.translate(
                                      context,
                                      'aboutThisPropLbl',
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: context.font.large,
                                    color: context.color.textColorDark,
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  if (property?.description != null) ...[
                                    ReadMoreText(
                                      text: property?.description ?? '',
                                      style: TextStyle(
                                        color: context.color.textColorDark,
                                      ),
                                      readMoreButtonStyle: TextStyle(
                                        color: context.color.tertiaryColor,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(
                                    height: 20,
                                  ),

                                  // TODO(R): This is for banner ads
                                  if (_bannerAd != null &&
                                      Constant.isAdmobAdsEnabled)
                                    SizedBox(
                                      width: _bannerAd?.size.width.toDouble(),
                                      height: _bannerAd?.size.height.toDouble(),
                                      child: AdWidget(ad: _bannerAd!),
                                    ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  if (widget.property?.assignedOutdoorFacility
                                          ?.isNotEmpty ??
                                      false) ...[
                                    CustomText(
                                      UiUtils.translate(
                                        context,
                                        'outdoorFacilities',
                                      ),
                                      fontWeight: FontWeight.w600,
                                      fontSize: context.font.large,
                                      color: context.color.textColorDark,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                  OutdoorFacilityListWidget(
                                    outdoorFacilityList: widget.property
                                            ?.assignedOutdoorFacility ??
                                        [],
                                  ),

                                  CustomText(
                                    UiUtils.translate(
                                      context,
                                      'listedBy',
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: context.font.large,
                                    color: context.color.textColorDark,
                                  ),
                                  const SizedBox(
                                    height: 14,
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: AgentProfileWidget(
                                      widget: widget,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  if (gallary?.isNotEmpty ?? false) ...[
                                    CustomText(
                                      UiUtils.translate(
                                        context,
                                        'gallery',
                                      ),
                                      fontWeight: FontWeight.w600,
                                      color: context.color.textColorDark,
                                      fontSize: context.font.large,
                                    ),
                                    SizedBox(
                                      height: 10.rh(context),
                                    ),
                                  ],
                                  if (gallary?.isNotEmpty ?? false) ...[
                                    Row(
                                      children: List.generate(
                                        gallary?.length.clamp(0, 4) ?? 0,
                                        (index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                18,
                                              ),
                                              child: Stack(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (gallary?[index]
                                                              .isVideo ??
                                                          false) {
                                                        return;
                                                      }
                                                      //google map doesn't allow blur so we hide it:)
                                                      showGoogleMap = false;
                                                      setState(() {});

                                                      final images = gallary
                                                          ?.map(
                                                            (e) => e.imageUrl,
                                                          )
                                                          .toList();

                                                      UiUtils.imageGallaryView(
                                                        context,
                                                        images: images!,
                                                        initalIndex: index,
                                                        then: () {
                                                          showGoogleMap = true;
                                                          setState(() {});
                                                        },
                                                      );
                                                    },
                                                    child: SizedBox(
                                                      width: 76.rw(context),
                                                      height: 76.rh(context),
                                                      child: gallary?[index]
                                                                  .isVideo ??
                                                              false
                                                          ? Container(
                                                              child: UiUtils
                                                                  .getImage(
                                                                youtubeVideoThumbnail,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            )
                                                          : UiUtils.getImage(
                                                              gallary?[index]
                                                                      .imageUrl ??
                                                                  '',
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                  ),
                                                  if (gallary?[index].isVideo ??
                                                      false)
                                                    Positioned.fill(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            CupertinoPageRoute<
                                                                dynamic>(
                                                              builder:
                                                                  (context) {
                                                                return VideoViewScreen(
                                                                  videoUrl:
                                                                      gallary?[index]
                                                                              .image ??
                                                                          '',
                                                                  flickManager:
                                                                      flickManager,
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        child: ColoredBox(
                                                          color: Colors.black
                                                              .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                          child: FittedBox(
                                                            fit: BoxFit.none,
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: context
                                                                    .color
                                                                    .tertiaryColor
                                                                    .withValues(
                                                                  alpha: 0.8,
                                                                ),
                                                              ),
                                                              width: 30,
                                                              height: 30,
                                                              child: const Icon(
                                                                Icons
                                                                    .play_arrow,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (index == 3)
                                                    Positioned.fill(
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            CupertinoPageRoute<
                                                                dynamic>(
                                                              builder:
                                                                  (context) {
                                                                return AllGallaryImages(
                                                                  youtubeThumbnail:
                                                                      youtubeVideoThumbnail,
                                                                  images: property
                                                                          ?.gallery ??
                                                                      [],
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          color: Colors.black
                                                              .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                          child: CustomText(
                                                            '+${(property?.gallery?.length ?? 0) - 3}',
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: context
                                                                .font.large,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  if (hasDocuments()) ...[
                                    CustomText(
                                      'Documents'.translate(context),
                                      fontWeight: FontWeight.bold,
                                      fontSize: context.font.large,
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final document =
                                            widget.property!.documents![index];
                                        return DownloadableDocuments(
                                          url: document.file!,
                                        );
                                      },
                                      itemCount:
                                          widget.property!.documents!.length,
                                    ),
                                  ],
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  CustomText(
                                    UiUtils.translate(
                                      context,
                                      'locationLbl',
                                    ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: context.font.large,
                                    color: context.color.textColorDark,
                                  ),
                                  SizedBox(
                                    height: 10.rh(context),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        "${UiUtils.translate(context, "addressLbl")} :",
                                        fontSize: context.font.normal,
                                        color: context.color.textColorDark,
                                      ),
                                      SizedBox(
                                        height: 5.rh(context),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          UiUtils.getSvg(
                                            AppIcons.location,
                                            color: context.color.tertiaryColor,
                                          ),
                                          SizedBox(
                                            width: 5.rw(context),
                                          ),
                                          Expanded(
                                            child: CustomText(
                                              property?.address ?? '',
                                              maxLines: 6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.rh(context),
                                  ),
                                  buildMapContainer(),
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  if (!HiveUtils.isGuest()) ...[
                                    if (int.parse(
                                          HiveUtils.getUserId() ?? '0',
                                        ) !=
                                        property?.addedBy)
                                      Row(
                                        children: [
                                          // sendEnquiryButtonWithState(),
                                          setInterest(),
                                        ],
                                      ),
                                  ],
                                  const SizedBox(
                                    height: 18,
                                  ),
                                  if (!reportedProperties.contains(
                                        widget.property!.id,
                                      ) &&
                                      widget.property!.addedBy.toString() !=
                                          HiveUtils.getUserId() &&
                                      !isReported)
                                    ReportPropertyButton(
                                      propertyId: property!.id!,
                                      onSuccess: () {
                                        setState(
                                          () {},
                                        );
                                      },
                                    ),
                                  const SizedBox(height: 18),
                                  buildSimilarProperties(),
                                ],
                              ),
                            //here
                            SizedBox(
                              height: 20.rh(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSimilarProperties() {
    return BlocBuilder<FetchSimilarPropertiesCubit,
        FetchSimilarPropertiesState>(
      builder: (context, state) {
        if (state is FetchSimilarPropertiesSuccess) {
          if (state.properties.isEmpty) {
            return const SizedBox.shrink();
          }
          if (widget.property?.requestStatus.toString() == 'pending' ||
              widget.property?.requestStatus.toString() == 'rejected') {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                UiUtils.translate(context, 'similarProperties'),
                fontWeight: FontWeight.w600,
                fontSize: context.font.large,
                color: context.color.textColorDark,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 390,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.properties.length,
                  itemBuilder: (context, index) {
                    return BlocProvider(
                      create: (context) {
                        return AddToFavoriteCubitCubit();
                      },
                      child: Container(
                        width: context.screenWidth * 0.75,
                        margin: const EdgeInsetsDirectional.only(end: 15),
                        child: PropertyCardBig(
                          key: UniqueKey(),
                          showEndPadding: true,
                          isFromCompare: true,
                          isFirst: index == 0,
                          property: state.properties[index],
                          sourceProperty: property,
                          onLikeChange: (type) {
                            if (type == FavoriteType.add) {
                              context
                                  .read<FetchFavoritesCubit>()
                                  .add(state.properties[index]);
                            } else {
                              context
                                  .read<FetchFavoritesCubit>()
                                  .remove(state.properties[index].id);
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
        return const SizedBox.shrink();
      },
    );
  }

  PopupMenuItem<String> buildPopupMenItem({
    required BuildContext context,
    required String title,
    required String icon,
    required int index,
  }) {
    return PopupMenuItem<String>(
      value: title,
      child: Row(
        children: [
          UiUtils.getSvg(
            icon,
          ),
          const SizedBox(
            width: 5,
          ),
          CustomText(
            title.translate(context),
          ),
        ],
      ),
    );
  }

  Widget buildMapContainer() {
    return SizedBox(
      height: 175,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/map.png',
              fit: BoxFit.cover,
            ),
            Center(
              child: MaterialButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute<dynamic>(
                      builder: (context) {
                        return Scaffold(
                          extendBodyBehindAppBar: true,
                          backgroundColor: context.color.primaryColor,
                          appBar: AppBar(
                            elevation: 0,
                            iconTheme: IconThemeData(
                              color: context.color.tertiaryColor,
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          body: GoogleMapScreen(
                            latitude: double.parse(
                              property?.latitude ?? '0',
                            ),
                            longitude: double.parse(
                              property?.longitude ?? '0',
                            ),
                            kInitialPlace: _kInitialPlace,
                            controller: _controller,
                          ),
                        );
                      },
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    5,
                  ),
                ),
                color: context.color.tertiaryColor,
                elevation: 0,
                child: CustomText(
                  'viewMap'.translate(
                    context,
                  ),
                  color: context.color.buttonColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEnableDisableSwitch() {
    return Column(
      children: [
        Row(
          children: [
            CustomText(
              'updatePropertyStatus'.translate(context),
              fontSize: context.font.large,
              color: context.color.tertiaryColor,
              fontWeight: FontWeight.w600,
            ),
            const Spacer(),
            ValueListenableBuilder(
              valueListenable: isEnabled,
              builder: (context, value, child) {
                return CupertinoSwitch(
                  activeTrackColor: context.color.tertiaryColor,
                  value: value,
                  onChanged: property?.requestStatus.toString() == 'pending'
                      ? null
                      : (newValue) async {
                          // Get current state to check if we're already in progress
                          final cubit =
                              context.read<ChangePropertyStatusCubit>();
                          final currentState = cubit.state;

                          if (currentState is ChangePropertyStatusInProgress) {
                            return;
                          }

                          final status = value == false ? 1 : 0;

                          // Update UI immediately for responsive feedback
                          setState(() {
                            isEnabled.value = newValue;
                          });

                          try {
                            // Make API call
                            await cubit.enableProperty(
                              propertyId: property!.id!,
                              status: status,
                            );

                            // Listen for state changes after API call completes
                            final newState = cubit.state;

                            if (newState is ChangePropertyStatusFailure) {
                              // If API failed, revert the UI change
                              setState(() {
                                isEnabled.value = !newValue;
                              });

                              final errorMessage =
                                  newState.error.contains('429')
                                      ? 'tooManyRequestsPleaseWait'
                                          .translate(context)
                                      : newState.error;

                              await HelperUtils.showSnackBarMessage(
                                context,
                                errorMessage,
                                type: MessageType.error,
                              );
                            }
                            // Success state is already reflected in UI
                          } catch (e) {
                            // Handle unexpected errors
                            setState(() {
                              isEnabled.value = !newValue;
                            });

                            await HelperUtils.showSnackBarMessage(
                              context,
                              'somethingWentWrong'.translate(context),
                              type: MessageType.error,
                            );
                          }
                        },
                );
              },
            ),
          ],
        ),
        const SizedBox(
          height: 7,
        ),
        const Divider(
          color: Colors.grey,
          height: 3,
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildMortgageCalculatorContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
          colors: [
            context.color.tertiaryColor.withValues(alpha: 0.1),
            context.color.primaryColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: context.color.inverseSurface.withValues(alpha: 0.2),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.color.tertiaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 50,
                width: 50,
                child: UiUtils.getSvg(
                  AppIcons.calculator,
                  color: Colors.white,
                  width: 40,
                  height: 40,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'calculateMortgage'.translate(context),
                      color: context.color.tertiaryColor,
                      fontSize: context.font.large,
                      fontWeight: FontWeight.w900,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    CustomText(
                      'tryMortgageCalculator'.translate(context),
                      color:
                          context.color.inverseSurface.withValues(alpha: 0.6),
                      fontSize: context.font.small,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Flexible(
            child: UiUtils.buildButton(
              context,
              padding: const EdgeInsetsDirectional.only(end: 10, start: 10),
              outerPadding:
                  const EdgeInsetsDirectional.only(start: 10, end: 10),
              height: 30,
              showElevation: false,
              buttonColor: Colors.transparent,
              border: BorderSide(
                color: context.color.tertiaryColor,
              ),
              onPressed: () async {
                try {
                  final checkPackage = CheckPackage();
                  final packageAvailable =
                      await checkPackage.checkPackageAvailable(
                    packageType: PackageType.mortgageCalculatorDetail,
                  );
                  if (packageAvailable) {
                    await showModalBottomSheet<dynamic>(
                      sheetAnimationStyle: AnimationStyle(
                        duration: const Duration(milliseconds: 500),
                        reverseDuration: const Duration(milliseconds: 200),
                      ),
                      showDragHandle: true,
                      backgroundColor: context.color.secondaryColor,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      context: context,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: MortgageCalculator(property: widget.property!),
                      ),
                    );
                  } else {
                    await UiUtils.showBlurredDialoge(
                      context,
                      dialog: const BlurredSubscriptionDialogBox(
                        packageType:
                            SubscriptionPackageType.mortgageCalculatorDetail,
                      ),
                    );
                  }
                } catch (e) {
                  log(e.toString());
                }
              },
              buttonTitle: 'tryNow'.translate(context),
              textColor: context.color.tertiaryColor,
              fontSize: 14,
              radius: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget advertisementLabel() {
    // if (property?.promoted == false || property?.promoted == null) {
    //   return const SizedBox.shrink();
    // }

    return PositionedDirectional(
      start: 20,
      top: 20,
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            if (property != null &&
                property?.allPropData['is_premium'] == true) ...[
              UiUtils.getSvg(
                AppIcons.premium,
                height: 20,
                width: 20,
              ),
            ],
            const SizedBox(
              width: 4,
            ),
            if ((property?.promoted ?? false) &&
                property?.promoted != null) ...[
              Container(
                width: 83,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.color.tertiaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomText(
                  UiUtils.translate(context, 'featured'),
                  fontSize: context.font.normal,
                  color: context.color.buttonColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget myPropertyButton({
    required Function() onPressed,
    required String title,
    required String icon,
    required bool disabled,
  }) {
    return Expanded(
      child: UiUtils.buildButton(
        context,
        height: 45.rh(context),
        disabled: disabled,
        outerPadding: const EdgeInsets.all(
          1,
        ),
        onPressed: onPressed,
        prefixWidget: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: SvgPicture.asset(
            icon,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(
              context.color.buttonColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        fontSize: context.font.normal,
        width: context.screenWidth / 3,
        buttonTitle: title,
      ),
    );
  }

  Widget bottomNavBar() {
    /// IF property is added by current user then it will show promote button
    if (!HiveUtils.isGuest()) {
      if (int.parse(HiveUtils.getUserId() ?? '0') == property?.addedBy) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            height: 45.rh(context),
            child: BlocBuilder<FetchMyPropertiesCubit, FetchMyPropertiesState>(
              builder: (context, state) {
                PropertyModel? model;

                if (state is FetchMyPropertiesSuccess) {
                  model = state.myProperty
                      .where((element) => element.id == property?.id)
                      .first;
                }

                model ??= widget.property;

                final isFeatureAvailable = model?.isFeatureAvailable;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!HiveUtils.isGuest() &&
                        Constant.isDemoModeOn != true) ...[
                      if (isFeatureAvailable ?? false) ...[
                        BlocBuilder<GetSubsctiptionPackageLimitsCubit,
                            GetSubscriptionPackageLimitsState>(
                          builder: (context, state) {
                            return myPropertyButton(
                              disabled: property?.status.toString() == '0' ||
                                  property?.advertisementStatus.toString() ==
                                      '1',
                              onPressed: () async {
                                await context
                                    .read<GetSubsctiptionPackageLimitsCubit>()
                                    .getLimits(
                                      packageType: 'property_feature',
                                    );
                                if (state
                                    is GetSubsctiptionPackageLimitsFailure) {
                                  await UiUtils.showBlurredDialoge(
                                    context,
                                    dialog: const BlurredSubscriptionDialogBox(
                                      packageType: SubscriptionPackageType
                                          .propertyFeature,
                                      isAcceptContainesPush: true,
                                    ),
                                  );
                                } else if (state
                                    is GetSubscriptionPackageLimitsSuccess) {
                                  if (state.error) {
                                    await UiUtils.showBlurredDialoge(
                                      context,
                                      dialog: BlurredDialogBox(
                                        title: state.message.firstUpperCase(),
                                        isAcceptContainesPush: true,
                                        onAccept: () async {
                                          await Navigator.popAndPushNamed(
                                            context,
                                            Routes.subscriptionPackageListRoute,
                                            arguments: {
                                              'from': 'propertyDetails',
                                              'isBankTransferEnabled': (context
                                                              .read<
                                                                  GetApiKeysCubit>()
                                                              .state
                                                          as GetApiKeysSuccess)
                                                      .bankTransferStatus ==
                                                  '1',
                                            },
                                          );
                                        },
                                        content: CustomText(
                                          'yourPackageLimitOver'
                                              .translate(context),
                                        ),
                                      ),
                                    );
                                  } else {
                                    try {
                                      await showDialog<dynamic>(
                                        context: context,
                                        builder: (context) =>
                                            CreateAdvertisementPopup(
                                          property: property!,
                                          isProject: false,
                                          project: ProjectModel(),
                                        ),
                                      );
                                    } catch (e) {
                                      await HelperUtils.showSnackBarMessage(
                                        context,
                                        e.toString(),
                                      );
                                    }
                                  }
                                }
                              },
                              icon: AppIcons.promoted,
                              title: UiUtils.translate(context, 'feature'),
                            );
                          },
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                    ],
                    myPropertyButton(
                      disabled: false,
                      icon: AppIcons.edit,
                      onPressed: () async {
                        if (Constant.isDemoModeOn) {
                          await HelperUtils.showSnackBarMessage(
                            context,
                            'Not valid in demo mode',
                          );
                          return;
                        }
                        unawaited(Widgets.showLoader(context));
                        if (AppSettings.isVerificationRequired == true &&
                            isProfileCompleted != true) {
                          await UiUtils.showBlurredDialoge(
                            context,
                            dialog: BlurredDialogBox(
                              title: 'completeProfile'.translate(context),
                              isAcceptContainesPush: true,
                              onAccept: () async {
                                await Navigator.popAndPushNamed(
                                  context,
                                  Routes.completeProfile,
                                  arguments: {
                                    'from': 'home',
                                    'navigateToHome': true,
                                  },
                                );
                              },
                              content: CustomText(
                                'completeProfileFirst'.translate(context),
                              ),
                            ),
                          );
                          Widgets.hideLoder(context);
                          return;
                        }
                        try {
                          // final checkPackage = CheckPackage();
                          // final packageAvailable =
                          //     await checkPackage.checkPackageAvailable(
                          //   packageType: PackageType.propertyList,
                          // );
                          final category =
                              await context.read<FetchCategoryCubit>().get(
                                    property!.category!.id!,
                                  );
                          // if (packageAvailable) {
                          final parameterIds = category.parameterTypes;
                          final mappedParameters = parameterIds?.map((id) {
                            // Find index of parameter in property parameters list
                            final index = property?.parameters?.indexWhere(
                                  (element) => element.id == id['id'],
                                ) ??
                                -1;

                            // If parameter found, return it; otherwise, return the original value
                            return index != -1
                                ? property!.parameters![index]
                                : id;
                          }).toList();
                          Constant.addProperty.addAll({
                            'category': Category(
                              category: property?.category!.category,
                              id: property?.category?.id,
                              image: property?.category?.image,
                              parameterTypes: mappedParameters,
                            ),
                          });
                          Widgets.hideLoder(context);

                          await Navigator.pushNamed(
                            context,
                            Routes.addPropertyDetailsScreen,
                            arguments: {
                              'properties': property?.toMap(),
                              'details': {
                                'id': property?.id,
                                'catId': property?.category?.id,
                                'propType': property?.properyType,
                                'name': property?.title,
                                'desc': property?.description,
                                'city': property?.city,
                                'state': property?.state,
                                'country': property?.country,
                                'latitude': property?.latitude,
                                'longitude': property?.longitude,
                                'address': property?.address,
                                'client': property?.clientAddress,
                                'price': property?.price,
                                'parms': property?.parameters,
                                'allPropData': property?.allPropData,
                                'images': property?.gallery
                                    ?.map((e) => e.imageUrl)
                                    .toList(),
                                'gallary_with_id': property?.gallery,
                                'rentduration': property?.rentduration,
                                'assign_facilities':
                                    property?.assignedOutdoorFacility,
                                'titleImage': property?.titleImage,
                                'slug_id': property?.slugId,
                                'three_d_image': property?.threeDImage,
                              },
                            },
                          );
                          // } else {
                          //   Widgets.hideLoder(context);
                          //   await UiUtils.showBlurredDialoge(
                          //     context,
                          //     dialog: const BlurredSubscriptionDialogBox(
                          //       packageType:
                          //           SubscriptionPackageType.propertyList,
                          //       isAcceptContainesPush: true,
                          //     ),
                          //   );
                          // }
                        } catch (e) {
                          Widgets.hideLoder(context);
                        } finally {
                          Widgets.hideLoder(context);
                        }
                      },
                      title: UiUtils.translate(context, 'edit'),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    myPropertyButton(
                      icon: AppIcons.delete,
                      disabled: false,
                      onPressed: () async {
                        // //THIS IS FOR DEMO MODE
                        final isPropertyActive =
                            property?.status.toString() == '1';

                        final isDemoNumber = HiveUtils.getUserDetails()
                                .mobile ==
                            '${Constant.demoCountryCode}${Constant.demoMobileNumber}';

                        if (Constant.isDemoModeOn &&
                            isPropertyActive &&
                            isDemoNumber) {
                          await HelperUtils.showSnackBarMessage(
                            context,
                            'Active property cannot be deleted in demo app.',
                          );

                          return;
                        }

                        final delete = await UiUtils.showBlurredDialoge(
                          context,
                          dialog: BlurredDialogBox(
                            title: UiUtils.translate(
                              context,
                              'deleteBtnLbl',
                            ),
                            content: CustomText(
                              UiUtils.translate(
                                context,
                                'deletepropertywarning',
                              ),
                              maxLines: 5,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                        if (delete == true) {
                          Future.delayed(
                            Duration.zero,
                            () {
                              context.read<DeletePropertyCubit>().delete(
                                    property!.id!,
                                  );
                            },
                          );
                        }
                      },
                      title: UiUtils.translate(context, 'deleteBtnLbl'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: 65.rh(context),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              children: <Widget>[
                Expanded(child: callButton()),
                const SizedBox(
                  width: 8,
                ),
                Expanded(child: messageButton()),
                const SizedBox(
                  width: 8,
                ),
                Expanded(child: chatButton()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget setInterest() {
    // check if list has this id or not
    final interestedProperty =
        Constant.interestedPropertyIds.contains(widget.property?.id);

    /// default icon
    dynamic icon = AppIcons.interested;

    /// first priority is Constant list .
    if (interestedProperty == true || widget.property?.isInterested == 1) {
      /// If list has id or our property is interested so we are gonna show icon of No Interest
      icon = Icons.not_interested_outlined;
    }

    return BlocConsumer<ChangeInterestInPropertyCubit,
        ChangeInterestInPropertyState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is ChangeInterestInPropertySuccess) {
          if (state.interest == PropertyInterest.interested) {
            //If interested show no interested icon
            icon = Icons.not_interested_outlined;
          } else {
            icon = AppIcons.interested;
          }
        }

        return Expanded(
          child: UiUtils.buildButton(
            context,
            height: 48,
            outerPadding: const EdgeInsets.all(1),
            isInProgress: state is ChangeInterestInPropertyInProgress,
            onPressed: () {
              PropertyInterest interest;

              final contains =
                  Constant.interestedPropertyIds.contains(widget.property!.id);

              if (contains == true || widget.property!.isInterested == 1) {
                //change to not interested
                interest = PropertyInterest.notInterested;
              } else {
                //change to not unterested
                interest = PropertyInterest.interested;
              }
              context.read<ChangeInterestInPropertyCubit>().changeInterest(
                    propertyId: widget.property!.id!.toString(),
                    interest: interest,
                  );
            },
            buttonTitle: (icon == Icons.not_interested_outlined
                ? UiUtils.translate(context, 'interested')
                : UiUtils.translate(context, 'interest')),
            fontSize: context.font.large,
            prefixWidget: Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: (icon is String)
                  ? SvgPicture.asset(
                      icon?.toString() ?? '',
                      width: 22,
                      height: 22,
                    )
                  : Icon(
                      icon as IconData,
                      color: Theme.of(context).colorScheme.buttonColor,
                      size: 22,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget callButton() {
    return UiUtils.buildButton(
      context,
      fontSize: context.font.large,
      outerPadding: const EdgeInsets.all(1),
      buttonTitle: UiUtils.translate(context, 'call'),
      height: 45.rh(context),
      onPressed: _onTapCall,
      prefixWidget: Container(
        margin: const EdgeInsets.only(right: 3, left: 3),
        child: SizedBox(
          width: 16,
          height: 16,
          child: UiUtils.getSvg(AppIcons.call, color: Colors.white),
        ),
      ),
    );
  }

  Widget messageButton() {
    return UiUtils.buildButton(
      context,
      fontSize: context.font.large,
      outerPadding: const EdgeInsets.all(1),
      buttonTitle: UiUtils.translate(context, 'sms'),
      height: 45.rh(context),
      onPressed: _onTapMessage,
      prefixWidget: SizedBox(
        width: 20,
        height: 20,
        child: Container(
          margin: const EdgeInsets.only(right: 3, left: 3),
          child: UiUtils.getSvg(
            AppIcons.message,
            color: context.color.buttonColor,
          ),
        ),
      ),
    );
  }

  Widget chatButton() {
    return UiUtils.buildButton(
      context,
      fontSize: context.font.large,
      outerPadding: const EdgeInsets.all(1),
      buttonTitle: UiUtils.translate(context, 'chat'),
      height: 45.rh(context),
      onPressed: _onTapChat,
      prefixWidget: SizedBox(
        width: 22,
        height: 22,
        child: Container(
          margin: const EdgeInsets.only(right: 3, left: 3),
          child:
              UiUtils.getSvg(AppIcons.chat, color: context.color.buttonColor),
        ),
      ),
    );
  }

  Future<void> _onTapCall() async {
    final contactNumber = widget.property?.customerNumber;

    final url = Uri.parse('tel: $contactNumber'); //{contactNumber.data}
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      log('Could not launch $url');
    }
  }

  Future<void> _onTapMessage() async {
    final contactNumber = widget.property?.customerNumber;

    final url = Uri.parse('sms: +$contactNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      log('Could not launch $url');
    }
  }

  void _onTapChat() {
    CheckInternet.check(
      onInternet: () async {
        await GuestChecker.check(
          onNotGuest: () async {
            final chatState = context.read<GetChatListCubit>().state;
            if (chatState is GetChatListSuccess) {
              await Navigator.push(
                context,
                CupertinoPageRoute<dynamic>(
                  builder: (context) {
                    return MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => SendMessageCubit(),
                        ),
                        BlocProvider(
                          create: (context) => LoadChatMessagesCubit(),
                        ),
                        BlocProvider(
                          create: (context) => DeleteMessageCubit(),
                        ),
                      ],
                      child: ChatScreenNew(
                        profilePicture: property?.customerProfile ?? '',
                        userName: property?.customerName ?? '',
                        propertyImage: property?.titleImage ?? '',
                        proeprtyTitle: property?.title ?? '',
                        userId: (property?.addedBy).toString(),
                        from: 'property',
                        propertyId: (property?.id).toString(),
                        isBlockedByMe: property?.isBlockedByMe ?? true,
                        isBlockedByUser: property?.isBlockedByUser ?? true,
                      ),
                    );
                  },
                ),
              );
            }
            if (chatState is GetChatListFailed) {
              await HelperUtils.showSnackBarMessage(
                context,
                chatState.error.toString(),
              );
            }
          },
        );
      },
      onNoInternet: () {
        HelperUtils.showSnackBarMessage(
          context,
          'noInternet'.translate(context),
        );
      },
    );
  }
}
