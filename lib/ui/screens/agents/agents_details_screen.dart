import 'package:ebroker/data/cubits/agents/fetch_project_by_agents_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_projects_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_by_agent_cubit.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/customer_data.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/agent_properties.dart';
import 'package:ebroker/ui/screens/agents/cards/agents_project_card.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AgentDetailsScreen extends StatefulWidget {
  const AgentDetailsScreen({
    required this.agent,
    required this.isAdmin,
    super.key,
  });
  final bool isAdmin;
  final CustomerData agent;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final argument = routeSettings.arguments! as Map;

    return BlurredRouter(
      builder: (_) => AgentDetailsScreen(
        agent: argument['agent'] as CustomerData,
        isAdmin: argument['isAdmin'] as bool,
      ),
    );
  }

  @override
  State<AgentDetailsScreen> createState() => _AgentDetailsScreenState();
}

class _AgentDetailsScreenState extends State<AgentDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool isPremiumProperty = true;
  bool isPremiumUser = false;
  bool showProjects = false;
  bool isProjectListEmpty = false;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    getAgentProjectsAndProperties();
  }

  Future<void> getAgentProjectsAndProperties() async {
    await context.read<FetchAgentsProjectCubit>().fetchAgentsProject(
          forceRefresh: true,
          agentId: widget.agent.id,
          isAdmin: widget.isAdmin,
        );
    await context.read<FetchAgentsPropertyCubit>().fetchAgentsProperty(
          agentId: widget.agent.id,
          forceRefresh: true,
          isAdmin: widget.isAdmin,
        );

    isProjectListEmpty = (context.read<FetchAgentsProjectCubit>().state
            as FetchAgentsProjectSuccess)
        .agentsProperty
        .projectData
        .isEmpty;
    showProjects = (context.read<FetchAgentsProjectCubit>().state
                as FetchAgentsProjectSuccess)
            .agentsProperty
            .customerData
            .projectCount !=
        0;
    _tabController = TabController(length: showProjects ? 3 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.backgroundColor,
      appBar: UiUtils.buildAppBar(
        context,
        title: UiUtils.translate(context, 'agentDetails'),
        showBackButton: true,
      ),
      body: buildAgentDetails(
        context,
        widget.agent,
      ),
    );
  }

  Widget buildAgentDetails(
    BuildContext context,
    CustomerData agent,
  ) {
    return BlocConsumer<FetchProjectByAgentCubit, FetchProjectByAgentState>(
      listener: (context, state) {
        if (state is FetchProjectByAgentSuccess) {
          HelperUtils.goToNextPage(
            Routes.projectDetailsScreen,
            context,
            false,
            args: {
              'project': state.project,
            },
          );
        }
      },
      builder: (context, state) {
        return BlocConsumer<FetchPropertyByAgentCubit,
            FetchPropertyByAgentState>(
          listener: (context, state) {
            if (state is FetchPropertyByAgentSuccess) {
              HelperUtils.goToNextPage(
                Routes.propertyDetails,
                context,
                false,
                args: {
                  'propertyData': state.property,
                },
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  margin: const EdgeInsets.only(
                    left: 18,
                    right: 18,
                    top: 18,
                  ),
                  decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    border: Border.all(
                      color: context.color.borderColor,
                      width: 1.5,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: UiUtils.getImage(
                            agent.profile,
                            width: MediaQuery.of(context).size.width * 0.30,
                            height: double.infinity,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: CustomText(
                                    agent.name.firstUpperCase(),
                                    maxLines: 2,
                                    fontWeight: FontWeight.w600,
                                    fontSize: context.font.normal,
                                  ),
                                ),
                                const SizedBox(
                                  width: 2,
                                ),
                                if (agent.isVerified ?? false)
                                  UiUtils.getSvg(
                                    AppIcons.agentBadge,
                                    height: 24,
                                    width: 24,
                                    color: context.color.tertiaryColor,
                                  ),
                                const SizedBox(
                                  width: 8,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            CustomText(
                              agent.email,
                              fontSize: context.font.small,
                            ),
                            if (agent.facebookId != '' ||
                                agent.twitterId != '' ||
                                agent.instagramId != '' ||
                                agent.youtubeId != '') ...[
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  CustomText(
                                    'followMe'.translate(context),
                                    fontSize: context.font.small,
                                  ),
                                  if (agent.facebookId != null &&
                                      agent.facebookId != '')
                                    socialButton(
                                      context: context,
                                      name: 'facebook',
                                      url: agent.facebookId ?? '',
                                    ),
                                  if (agent.twitterId != null &&
                                      agent.twitterId != '')
                                    socialButton(
                                      context: context,
                                      name: 'twitter',
                                      url: agent.twitterId ?? '',
                                    ),
                                  if (agent.instagramId != null &&
                                      agent.instagramId != '')
                                    socialButton(
                                      context: context,
                                      name: 'instagram',
                                      url: agent.instagramId ?? '',
                                    ),
                                  if (agent.youtubeId != null &&
                                      agent.youtubeId != '')
                                    socialButton(
                                      context: context,
                                      name: 'youtube',
                                      url: agent.youtubeId ?? '',
                                    ),
                                ],
                              ),
                            ],
                            Expanded(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  callButton(context),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  emailButton(context),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<FetchAgentsPropertyCubit, FetchAgentsPropertyState>(
                  builder: (context, state) {
                    if (state is FetchAgentsPropertyFailure) {
                      return Container(
                        margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1,
                        ),
                        child: const SomethingWentWrong(),
                      );
                    }
                    if (state is FetchAgentsPropertyLoading) {
                      return Expanded(
                        child: Container(
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width,
                          child: const CustomShimmer(
                            margin: EdgeInsets.all(15),
                            borderRadius: 8,
                          ),
                        ),
                      );
                    }
                    if (state is FetchAgentsPropertySuccess) {
                      return Expanded(
                        child: Container(
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width,
                          child: DefaultTabController(
                            length: showProjects ? 3 : 2,
                            child: Column(
                              children: [
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(
                                    left: 18,
                                    right: 18,
                                    top: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.color.secondaryColor,
                                    border: Border.all(
                                      color: context.color.borderColor,
                                      width: 1.5,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  child: TabBar(
                                    controller:
                                        _tabController, // Use the controller here
                                    indicatorPadding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    indicatorColor: context.color.tertiaryColor,
                                    labelColor: context.color.tertiaryColor,
                                    unselectedLabelColor:
                                        context.color.inverseSurface,
                                    tabs: [
                                      Tab(
                                        text: UiUtils.translate(
                                          context,
                                          'details',
                                        ),
                                      ),
                                      Tab(
                                        text: UiUtils.translate(
                                          context,
                                          'properties',
                                        ),
                                      ),
                                      if (showProjects)
                                        Tab(
                                          text: UiUtils.translate(
                                            context,
                                            'projects',
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    controller:
                                        _tabController, // Use the controller here

                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      detailsTab(
                                        context,
                                        state.agentsProperty.customerData,
                                      ),
                                      AgentProperties(
                                        agentId: state
                                            .agentsProperty.customerData.id,
                                        isAdmin: widget.isAdmin,
                                      ),
                                      if (showProjects && !isProjectListEmpty)
                                        AgentProjects(
                                          agentId: state
                                              .agentsProperty.customerData.id,
                                          isAdmin: widget.isAdmin,
                                        ),
                                      if (showProjects && isProjectListEmpty)
                                        Builder(
                                          builder: (context) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                              UiUtils.showBlurredDialoge(
                                                context,
                                                dialoge:
                                                    const BlurredSubscriptionDialogBox(
                                                  packageType:
                                                      SubscriptionPackageType
                                                          .projectAccess,
                                                  isAcceptContainesPush: true,
                                                ),
                                              );
                                            });
                                            Future.delayed(
                                                const Duration(
                                                  milliseconds: 300,
                                                ), () {
                                              _tabController!.index = 1;
                                            });
                                            return Container();
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                if (state.agentsProperty.premiumPropertyCount !=
                                        0 &&
                                    state.agentsProperty.isPackageAvailable ==
                                        false &&
                                    state.agentsProperty.isFeatureAvailable ==
                                        false)
                                  bottomButton(
                                    projectOrPropertyCount: state
                                        .agentsProperty.premiumPropertyCount,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget socialButton({
    required BuildContext context,
    required String name,
    required String url,
  }) {
    final String iconName;
    switch (name) {
      case 'facebook':
        iconName = AppIcons.facebook;
      case 'twitter':
        iconName = AppIcons.twitter;
      case 'instagram':
        iconName = AppIcons.instagram;
      case 'youtube':
        iconName = AppIcons.youtube;
      default:
        iconName = '';
    }
    if (iconName == '') {
      return const SizedBox.shrink();
    }
    final uri = Uri.parse(url);
    return GestureDetector(
      onTap: () {
        _launchUrl(uri);
      },
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 2),
        child: UiUtils.getSvg(
          iconName,
          height: 18,
          width: 18,
          color: context.color.tertiaryColor,
        ),
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget bottomButton({required int projectOrPropertyCount}) {
    return Container(
      color: context.color.secondaryColor,
      padding: const EdgeInsetsDirectional.only(
        start: 18,
        end: 18,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: 12,
              bottom: 8,
              top: 8,
            ),
            child: Row(
              children: [
                UiUtils.getSvg(
                  AppIcons.info,
                  height: 20,
                  width: 20,
                ),
                const SizedBox(
                  width: 4,
                ),
                CustomText(
                  '${'unlock'.translate(context)} $projectOrPropertyCount ${'premiumProperties'.translate(context)}',
                  fontSize: context.font.normal,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          UiUtils.buildButton(
            context,
            onPressed: () async {
              await Navigator.pushNamed(
                context,
                Routes.subscriptionPackageListRoute,
                arguments: {'from': 'agentDetails'},
              );
            },
            height: 48.rh(context),
            fontSize: context.font.large,
            buttonTitle: UiUtils.translate(context, 'unlockPremium'),
          ),
        ],
      ),
    );
  }

  Widget detailsTab(BuildContext context, CustomerData customerData) {
    return Container(
      margin: const EdgeInsets.only(
        top: 15,
        left: 18,
        right: 18,
        bottom: 30,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        border: Border.all(
          color: context.color.borderColor,
          width: 1.5,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: SingleChildScrollView(
        physics: Constant.scrollPhysics,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              customerData.aboutMe ?? '',
            ),
            const SizedBox(height: 14),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  color: context.color.inverseSurface,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '${'number'.translate(context)}: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: customerData.mobile),
                ],
              ),
            ),
            if (locationName(context: context, customerData: customerData)
                .isNotEmpty) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Flexible(
                    child: CustomText(
                      '${'location'.translate(context)}: ',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CustomText(
                    locationName(context: context, customerData: customerData)
                        .join(),
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ],
            if (customerData.address!.isNotEmpty &&
                customerData.address != null &&
                customerData.address != 'null') ...[
              const SizedBox(height: 14),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: context.color.inverseSurface,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${'operationalArea'.translate(context)}: ',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: customerData.address ?? ''),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  List<String> locationName({
    required BuildContext context,
    required CustomerData customerData,
  }) {
    final location = <String>[
      if (customerData.city!.isNotEmpty) '${customerData.city}',
      if (customerData.state!.isNotEmpty) ...[
        if (customerData.city!.isNotEmpty) ', ',
        '${customerData.state}',
      ],
      if (customerData.country!.isNotEmpty) ...[
        if (customerData.state!.isNotEmpty || customerData.city!.isNotEmpty)
          ',',
        '${customerData.country}',
      ],
    ];

    if (location.isEmpty) {
      return [];
    } else {
      return location;
    }
  }

  Widget callButton(BuildContext context) {
    return UiUtils.buildButton(
      context,
      fontSize: context.font.normal,
      buttonTitle: UiUtils.translate(context, 'call'),
      radius: 5,
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.038,
      onPressed: _onTapCall,
      prefixWidget: Padding(
        padding: const EdgeInsetsDirectional.only(end: 3),
        child: SizedBox(
          width: 16,
          height: 16,
          child: UiUtils.getSvg(AppIcons.call, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _onTapCall() async {
    GuestChecker.check(
      onNotGuest: () async {
        final contactNumber = widget.agent.mobile;
        final url = Uri.parse('tel: +$contactNumber'); //{contactNumber.data}
        try {
          await launchUrl(url);
        } catch (e) {
          throw Exception('Error calling $e');
        }
      },
    );
  }

  Widget emailButton(BuildContext context) {
    return UiUtils.buildButton(
      context,
      fontSize: context.font.normal,
      textColor: context.color.tertiaryColor,
      buttonTitle: UiUtils.translate(context, 'Email'),
      buttonColor: context.color.backgroundColor,
      border: BorderSide(color: context.color.tertiaryColor),
      radius: 5,
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.038,
      onPressed: _onTapEmail,
      prefixWidget: Container(
        margin: const EdgeInsetsDirectional.only(end: 6),
        child: UiUtils.getSvg(
          AppIcons.email,
          height: 16,
          width: 16,
        ),
      ),
    );
  }

  Future<void> _onTapEmail() async {
    GuestChecker.check(
      onNotGuest: () async {
        final email = widget.agent.email;
        final url = Uri.parse('mailto: +$email');
        try {
          await launchUrl(url);
        } catch (e) {
          throw Exception('Error mail $e');
        }
      },
    );
  }
}
