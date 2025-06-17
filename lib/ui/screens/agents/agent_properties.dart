import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/cards/agent_property_card.dart';
import 'package:flutter/material.dart';

class AgentProperties extends StatefulWidget {
  const AgentProperties({
    required this.agentId,
    required this.isAdmin,
    super.key,
  });
  final bool isAdmin;
  final String agentId;

  @override
  State<AgentProperties> createState() => _AgentPropertiesState();
}

class _AgentPropertiesState extends State<AgentProperties> {
  ///This Scroll controller for listen page end
  final ScrollController _pageScrollController = ScrollController();

  @override
  void initState() {
    _pageScrollController.addListener(onPageEnd);
    super.initState();
  }

  ///This method will listen page scroll changes
  void onPageEnd() {
    ///This is extension which will check if we reached end or not
    if (_pageScrollController.isEndReached()) {
      if (context.read<FetchAgentsPropertyCubit>().hasMoreData()) {
        context.read<FetchAgentsPropertyCubit>().fetchMore(
              isAdmin: widget.isAdmin,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<FetchAgentsPropertyCubit, FetchAgentsPropertyState>(
        builder: (agentsContext, state) {
          if (state is FetchAgentsPropertyLoading) {
            return Center(child: UiUtils.progress());
          }
          if (state is FetchAgentsPropertySuccess &&
              state.agentsProperty.propertiesData.isEmpty) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(
                  top: 15,
                  left: 18,
                  right: 18,
                  bottom: 8,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                child: NoDataFound(
                  height: MediaQuery.of(context).size.height * 0.25,
                  onTap: () {
                    context
                        .read<FetchAgentsPropertyCubit>()
                        .fetchAgentsProperty(
                          agentId: widget.agentId,
                          forceRefresh: true,
                          isAdmin: widget.isAdmin,
                        );
                  },
                ),
              ),
            );
          }
          if (state is FetchAgentsPropertySuccess &&
              state.agentsProperty.propertiesData.isNotEmpty) {
            return Flexible(
              child: Container(
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.only(
                  top: 15,
                  left: 18,
                  right: 18,
                  bottom: 8,
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
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        top: 15,
                        left: 18,
                        right: 18,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 12,
                      ),
                      height: 36,
                      width: MediaQuery.of(context).size.width * 0.9,
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
                      child: CustomText(
                        fontSize: 16,
                        color: context.color.inverseSurface,
                        fontWeight: FontWeight.w700,
                        '${state.agentsProperty.customerData.propertyCount} ${UiUtils.translate(context, 'properties')}',
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: Constant.scrollPhysics,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        controller: _pageScrollController,
                        itemCount: state.agentsProperty.propertiesData.length,
                        itemBuilder: (context, index) {
                          final agentsProperty =
                              state.agentsProperty.propertiesData[index];
                          return PropertyCard(
                            agentPropertiesData: agentsProperty,
                          );
                        },
                      ),
                    ),
                    if (context
                        .watch<FetchAgentsPropertyCubit>()
                        .isLoadingMore()) ...[
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: UiUtils.progress(
                          height: 24.rh(context),
                          width: 24.rw(context),
                        ),
                      ),
                    ],
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
