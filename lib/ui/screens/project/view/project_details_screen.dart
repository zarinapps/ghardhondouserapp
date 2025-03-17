import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/cubits/project/delete_project_cubit.dart';
import 'package:ebroker/data/cubits/project/fetchMyProjectsListCubit.dart';
import 'package:ebroker/data/cubits/project/fetchProjectDetailsCubit.dart';
import 'package:ebroker/data/helper/widgets.dart';
import 'package:ebroker/data/model/project_model.dart';
import 'package:ebroker/data/repositories/system_repository.dart';
import 'package:ebroker/ui/screens/proprties/property_details.dart';
import 'package:ebroker/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:ebroker/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:ebroker/ui/screens/widgets/gallery_view.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/cloud_state/cloud_state.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/typedefs.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:ebroker/utils/video_player/video_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectDetailsScreen extends StatefulWidget {
  const ProjectDetailsScreen({
    required this.project,
    super.key,
  });
  final ProjectModel project;
  static BlurredRouter route(RouteSettings settings) {
    final arguement = settings.arguments as Map?;
    return BlurredRouter(
      builder: (context) {
        return BlocProvider(
          create: (context) => DeleteProjectCubit(),
          child: ProjectDetailsScreen(
            project: arguement?['project'],
          ),
        );
      },
    );
  }

  @override
  CloudState<ProjectDetailsScreen> createState() =>
      _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends CloudState<ProjectDetailsScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool isMyProject = false;
  late final ProjectModel project;
  late final CameraPosition _kInitialPlace = CameraPosition(
    target: LatLng(
      double.parse(project.latitude!),
      double.parse(project.longitude!),
    ),
    zoom: 14.4746,
  );

  @override
  void initState() {
    project = widget.project;
    // getProjectDetails();
    isMyProject = checkIsProjectMine();
    super.initState();
  }

  // Future<void> getProjectDetails() async {
  //   await context.read<FetchProjectDetailsCubit>().fetchProjectDetails(
  //         projectId: widget.project.id!,
  //       );
  // }

  bool checkIsProjectMine() {
    return project.addedBy.toString() == HiveUtils.getUserId();
  }

  bool hasFloors() {
    return project.plans!.isNotEmpty;
  }

  bool hasDocuments() {
    return project.documents!.isNotEmpty;
  }

  bool readMore = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      bottomNavigationBar: BottomAppBar(
        color: context.color.secondaryColor,
        child: bottomNavigation(context),
      ),
      body: Builder(
        builder: (context) {
          return Padding(
            padding: EdgeInsets.zero,
            child: BlocListener<DeleteProjectCubit, DeleteProjectState>(
              listener: (context, state) {
                if (state is DeleteProjectInProgress) {
                  Widgets.showLoader(context);
                }
                if (state is DeleteProjectSuccess) {
                  Widgets.hideLoder(context);
                  context.read<FetchMyProjectsListCubit>().delete(state.id);

                  Navigator.pop(
                    context,
                  );
                }
              },
              child: BlocListener<FetchProjectDetailsCubit,
                  FetchProjectDetailsState>(
                listener: (context, state) {
                  if (state is FetchProjectDetailsInProgress) {
                    Widgets.showLoader(context);
                  }
                  if (state is FetchProjectDetailsSuccess) {
                    Widgets.hideLoder(context);
                    setState(() {
                      project = state.project;
                    });
                  }
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      systemOverlayStyle: const SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                      ),
                      shadowColor:
                          context.color.inverseSurface.withValues(alpha: 0.3),
                      leadingWidth: MediaQuery.of(context).size.width * 0.20,
                      backgroundColor: context.color.secondaryColor,
                      leading: Container(
                        margin: const EdgeInsetsDirectional.only(
                          start: 18,
                          top: 4,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Material(
                          clipBehavior: Clip.antiAlias,
                          color: context.color.secondaryColor,
                          borderOnForeground: false,
                          type: MaterialType.circle,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: UiUtils.getSvg(
                                AppIcons.arrowLeft,
                                matchTextDirection: true,
                                fit: BoxFit.none,
                                color: context.color.tertiaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      pinned: true,
                      expandedHeight: context.screenHeight * 0.35,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      centerTitle: true,
                      snap: true,
                      floating: true,
                      flexibleSpace: FlexibleSpaceBar(
                        collapseMode: CollapseMode.pin,
                        background: ProjectImageCareusel(
                          images: [
                            ...{project.image!},
                            ...project.gallaryImages!.map((e) => e.name!),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                categoryCard(context, project),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: context.color.tertiaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: CustomText(
                                    project.type!.translate(context),
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.font.small,
                                    color: context.color.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            CustomText(
                              project.title!,
                              fontWeight: FontWeight.w400,
                              fontSize: context.font.larger,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            CustomText(
                              project.description!.trim(),
                              maxLines: readMore ? 999999 : 3,
                              color: context.color.textColorDark
                                  .withValues(alpha: 0.89),
                            ),
                            TextButton(
                              style: ButtonStyle(
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.zero,
                                ),
                                overlayColor: WidgetStateProperty.all(
                                  context.color.tertiaryColor
                                      .withValues(alpha: 0.1),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  readMore = !readMore;
                                });
                              },
                              child: CustomText(
                                readMore
                                    ? 'readLessLbl'.translate(context)
                                    : 'readMoreLbl'.translate(context),
                                color: context.color.tertiaryColor,
                              ),
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                            ContactDetailsWidget(
                              url: project.customer?.profile ?? '',
                              number: project.customer?.mobile ?? '',
                              name: project.customer?.name ?? '',
                              email: project.customer?.email ?? '',
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            if (project.videoLink != null &&
                                project.videoLink!.isNotEmpty)
                              VideoPlayerWideget(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                url: project.videoLink!,
                              ),
                            if (hasDocuments()) ...[
                              Container(
                                  decoration: BoxDecoration(
                                    color: context.color.secondaryColor,
                                    border: Border.all(
                                      color: context.color.borderColor,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  alignment: AlignmentDirectional.centerStart,
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 10,
                                  ),
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                  child: CustomText(
                                    'Documents'.translate(context),
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.font.large,
                                  )),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: context.color.secondaryColor,
                                  border: Border.all(
                                    color: context.color.borderColor,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                padding: const EdgeInsetsDirectional.only(
                                  start: 10,
                                ),
                                child: ListView.separated(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  separatorBuilder: (context, index) => Divider(
                                    color: context.color.borderColor,
                                    height: 18,
                                    thickness: 1,
                                    endIndent: 10,
                                    indent: 10,
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final document = project.documents?[index];
                                    return DownloadableDocument(
                                      url: document!.name!,
                                    );
                                  },
                                  itemCount: project.documents?.length ?? 0,
                                ),
                              ),
                            ],
                            const SizedBox(
                              height: 15,
                            ),
                            if (hasFloors()) ...[
                              Container(
                                  decoration: BoxDecoration(
                                    color: context.color.secondaryColor,
                                    border: Border.all(
                                      color: context.color.borderColor,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  alignment: AlignmentDirectional.centerStart,
                                  padding: const EdgeInsetsDirectional.only(
                                    start: 10,
                                  ),
                                  height: 40,
                                  width: MediaQuery.of(context).size.width,
                                  child: CustomText(
                                    'floorPlans'.translate(context),
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.font.large,
                                  )),
                              Container(
                                decoration: BoxDecoration(
                                  color: context.color.secondaryColor,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  border: Border.all(
                                    color: context.color.borderColor,
                                  ),
                                ),
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: project.plans?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final floor = project.plans![index];
                                    return CustomExpansionTile(
                                      title: floor.title!,
                                      children: [
                                        Image.network(floor.document!),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                            ],
                            Container(
                                alignment: AlignmentDirectional.centerStart,
                                decoration: BoxDecoration(
                                  color: context.color.secondaryColor,
                                  border: Border.all(
                                    color: context.color.borderColor,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                padding: const EdgeInsetsDirectional.only(
                                  start: 10,
                                ),
                                height: 40,
                                width: MediaQuery.of(context).size.width,
                                child: CustomText(
                                  'projectLocation'.translate(context),
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.font.large,
                                )),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: context.color.secondaryColor,
                                border: Border.all(
                                  color: context.color.borderColor,
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              padding: const EdgeInsetsDirectional.all(18),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        'locationLblProj'.translate(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      Flexible(
                                        child: CustomText(
                                          project.location!,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      CustomText(
                                        'cityProj'.translate(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      CustomText(project.city!),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      CustomText(
                                        'stateProj'.translate(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      CustomText(project.state!),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      CustomText(
                                        'countryProj'.translate(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      CustomText(project.country!),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
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
                                          BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 4,
                                              sigmaY: 4,
                                            ),
                                            child: Center(
                                              child: MaterialButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    BlurredRouter(
                                                      builder: (context) {
                                                        return Scaffold(
                                                          extendBodyBehindAppBar:
                                                              true,
                                                          appBar: AppBar(
                                                            elevation: 0,
                                                            iconTheme:
                                                                IconThemeData(
                                                              color: context
                                                                  .color
                                                                  .tertiaryColor,
                                                            ),
                                                            backgroundColor:
                                                                Colors
                                                                    .transparent,
                                                          ),
                                                          body: GoogleMapScreen(
                                                            latitude:
                                                                double.parse(
                                                              project.latitude!,
                                                            ),
                                                            longitude:
                                                                double.parse(
                                                              project
                                                                  .longitude!,
                                                            ),
                                                            kInitialPlace:
                                                                _kInitialPlace,
                                                            controller:
                                                                _controller,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                color:
                                                    context.color.tertiaryColor,
                                                elevation: 0,
                                                child: CustomText(
                                                  'viewMap'.translate(context),
                                                  color:
                                                      context.color.buttonColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget bottomNavigation(BuildContext context) {
    if (isMyProject) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 65.rh(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: UiUtils.buildButton(
                    context,
                    // padding: const EdgeInsets.symmetric(horizontal: 1),
                    outerPadding: const EdgeInsets.all(1),
                    onPressed: () async {
                      try {
                        unawaited(Widgets.showLoader(context));
                        final systemRepository = SystemRepository();
                        final settings =
                            await systemRepository.fetchSystemSettings(
                          isAnonymouse: false,
                        );
                        if (settings['data']['is_premium'] == true) {
                          if (Constant.isDemoModeOn) {
                            await HelperUtils.showSnackBarMessage(
                              context,
                              'Not valid in demo mode',
                            );
                            return;
                          }
                          await Navigator.pushNamed(
                            context,
                            Routes.addProjectDetails,
                            arguments: {
                              'id': project.id,
                              'meta_title': project.metaTitle,
                              'meta_description': project.metaDescription,
                              'meta_image': project.metaImage,
                              'slug_id': project.slugId,
                              'category_id': project.category!.id,
                              'project': project.toMap(),
                            },
                          );
                          Widgets.hideLoder(context);
                        } else {
                          Widgets.hideLoder(context);
                          await UiUtils.showBlurredDialoge(
                            context,
                            dialoge: BlurredDialogBox(
                              title: 'Subscription needed',
                              isAcceptContainesPush: true,
                              onAccept: () async {
                                await Navigator.popAndPushNamed(
                                  context,
                                  Routes.subscriptionPackageListRoute,
                                  arguments: {'from': 'propertyDetails'},
                                );
                              },
                              content: CustomText(
                                'subscribeToUseThisFeature'.translate(context),
                              ),
                            ),
                          );
                        }
                        Widgets.hideLoder(context);
                      } catch (e) {
                        Widgets.hideLoder(context);
                        await HelperUtils.showSnackBarMessage(
                          context,
                          'somethingWentWrng'.translate(context),
                        );
                      }
                    },
                    fontSize: context.font.normal,
                    width: context.screenWidth / 3,
                    prefixWidget: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: SvgPicture.asset(AppIcons.edit),
                    ),
                    buttonTitle: UiUtils.translate(context, 'edit'),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: UiUtils.buildButton(
                    context,
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    outerPadding: const EdgeInsets.all(1),
                    prefixWidget: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: SvgPicture.asset(
                        AppIcons.delete,
                        colorFilter: ColorFilter.mode(
                          context.color.buttonColor,
                          BlendMode.srcIn,
                        ),
                        width: 14,
                        height: 14,
                      ),
                    ),
                    onPressed: () async {
                      log('is demo mode ${Constant.isDemoModeOn}');
                      if (Constant.isDemoModeOn) {
                        await HelperUtils.showSnackBarMessage(
                          context,
                          'Not valid in demo mode',
                        );

                        return;
                      }

                      await UiUtils.showBlurredDialoge(
                        context,
                        dialoge: BlurredDialogBox(
                          title: 'areYouSure'.translate(context),
                          onAccept: () async {
                            context.read<DeleteProjectCubit>().delete(
                                  project.id!,
                                );
                          },
                          content: CustomText(
                            'projectWillNotRecover'.translate(context),
                          ),
                        ),
                      );
                    },
                    fontSize: context.font.normal,
                    width: context.screenWidth / 3.2,
                    buttonTitle: UiUtils.translate(context, 'deleteBtnLbl'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

Widget categoryCard(BuildContext context, ProjectModel project) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.4,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        UiUtils.imageType(
          project.category!.image ?? '',
          width: 18,
          height: 18,
          color:
              Constant.adaptThemeColorSvg ? context.color.tertiaryColor : null,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: CustomText(
            project.category!.category!,
            color: context.color.inverseSurface.withValues(alpha: 0.4),
            fontSize: context.font.large,
          ),
        ),
      ],
    ),
  );
}

class ProjectImageCareusel extends StatefulWidget {
  const ProjectImageCareusel({
    required this.images,
    super.key,
  });
  final List<String> images;

  @override
  State<ProjectImageCareusel> createState() => _ProjectImageCareuselState();
}

class _ProjectImageCareuselState extends State<ProjectImageCareusel>
    with AutomaticKeepAliveClientMixin {
  final ValueNotifier<int> _sliderIndex = ValueNotifier(0);
  final PageController _pageController = PageController();
  late Timer _timer;
  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_sliderIndex.value < widget.images.length - 1) {
        _sliderIndex.value++;
      } else {
        _sliderIndex.value = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _sliderIndex.value,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn,
        );
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _sliderIndex.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.images.length,
          controller: _pageController,
          clipBehavior: Clip.antiAlias,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            _sliderIndex.value = index;
          },
          itemBuilder: (context, index) {
            final List images = widget.images;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  BlurredRouter(
                    builder: (context) => GalleryViewWidget(
                      images: images,
                      initalIndex: index,
                    ),
                  ),
                );
              },
              child: ProjectCateuseItem(
                url: widget.images[index],
              ),
            );
          },
        ),
        Align(
          alignment: Alignment.bottomCenter.add(const Alignment(0, -0.05)),
          child: ValueListenableBuilder(
            valueListenable: _sliderIndex,
            builder: (context, val, ch) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(
                    widget.images.length,
                    (index) => Container(
                      width: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == val
                            ? context.color.tertiaryColor
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ProjectCateuseItem extends StatelessWidget {
  const ProjectCateuseItem({
    required this.url,
    super.key,
  });
  final String url;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          url,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 8, sigmaX: 8),
          child: Container(
            color: Colors.black.withValues(alpha: 0.2),
          ),
        ),
        Image.network(
          url,
          fit: BoxFit.cover,
        ),
      ],
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  const CustomExpansionTile({
    required this.title,
    required this.children,
    super.key,
  });
  final String title;
  final Widgetss children;

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 2),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: context.color.backgroundColor,
        border: Border.all(
          color: context.color.borderColor,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: context.color.backgroundColor,
        title: CustomText(
          widget.title,
          color: context.color.inverseSurface.withValues(alpha: 0.9),
          fontSize: context.font.large,
        ),
        collapsedTextColor: context.color.inverseSurface,
        textColor: context.color.inverseSurface,
        iconColor: context.color.tertiaryColor,
        collapsedIconColor: context.color.tertiaryColor,
        trailing: AnimatedCrossFade(
          firstChild: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: context.color.tertiaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                width: 2,
                color: context.color.tertiaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.add,
              size: 30,
            ),
          ),
          secondChild: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: context.color.tertiaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                width: 2,
                color: context.color.tertiaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.remove,
              size: 30,
            ),
          ),
          duration: const Duration(milliseconds: 300),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          excludeBottomFocus: false,
        ),
        onExpansionChanged: (value) {
          isExpanded = value;
          setState(() {});
        },
        children: widget.children,
      ),
    );
  }
}

class ContactDetailsWidget extends StatelessWidget {
  const ContactDetailsWidget({
    required this.url,
    required this.name,
    required this.email,
    required this.number,
    super.key,
  });
  final String url;
  final String name;
  final String email;
  final String number;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          'contactUS'.translate(context),
          fontWeight: FontWeight.bold,
          fontSize: context.font.large,
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                UiUtils.showFullScreenImage(
                  context,
                  provider: NetworkImage(url),
                );
              },
              child: Container(
                width: 70,
                height: 70,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: UiUtils.getImage(url, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    name,
                    maxLines: 1,
                    fontWeight: FontWeight.bold,
                    fontSize: context.font.large,
                  ),
                  CustomText(
                    email,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.color.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: context.color.secondaryColor,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      await launchUrl(Uri.parse('mailto:$email'));
                    },
                    icon: Icon(
                      Icons.email,
                      color: context.color.tertiaryColor,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: context.color.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    color: context.color.secondaryColor,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      await launchUrl(Uri.parse('tel:+$number'));
                    },
                    icon: Icon(
                      Icons.call,
                      color: context.color.tertiaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class DownloadableDocument extends StatefulWidget {
  const DownloadableDocument({required this.url, super.key});
  final String url;

  @override
  State<DownloadableDocument> createState() => _DownloadableDocumentState();
}

class _DownloadableDocumentState extends State<DownloadableDocument> {
  bool downloaded = false;
  Dio dio = Dio();
  ValueNotifier<double> percentage = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  Future<String?>? path() async {
    final downloadPath = await HelperUtils.getDownloadPath();
    return downloadPath;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.url.split('/').last;
    return ListTile(
      dense: true,
      title: CustomText(
        name,
        color: context.color.textColorDark.withValues(alpha: 0.9),
        fontSize: context.font.normal,
      ),
      trailing: ValueListenableBuilder(
        valueListenable: percentage,
        builder: (context, value, child) {
          if (value != 0.0 && value != 1.0) {
            return SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                value: value,
                color: context.color.tertiaryColor,
              ),
            );
          }
          if (downloaded) {
            return Container(
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: context.color.borderColor,
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                splashRadius: 1,
                icon: Icon(
                  Icons.file_open,
                  color: context.color.tertiaryColor,
                ),
                onPressed: () async {
                  final downloadPath = await path();

                  await OpenFilex.open('$downloadPath/$name');
                },
              ),
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: context.color.borderColor,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              splashRadius: 1,
              icon: Icon(
                Icons.download,
                color: context.color.tertiaryColor,
              ),
              onPressed: () async {
                final downloadPath = await path();
                final storagePermission =
                    await HelperUtils.hasStoragePermissionGiven();
                if (storagePermission) {
                  await dio.download(
                    widget.url,
                    '$downloadPath/$name',
                    onReceiveProgress: (count, total) async {
                      percentage.value = count / total;
                      if (percentage.value == 1.0) {
                        downloaded = true;
                        setState(() {});
                        await OpenFilex.open('$downloadPath/$name');
                      }
                    },
                  );
                } else {
                  await HelperUtils.showSnackBarMessage(
                    context,
                    'Storage Permission denied!',
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
