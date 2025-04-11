import 'dart:async';

import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/data/model/agent/agent_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class AgentCard extends StatelessWidget {
  const AgentCard({
    required this.agent,
    required this.propertyCount,
    required this.name,
    super.key,
    this.isFirst,
    this.showEndPadding,
  });

  final AgentModel agent;
  final bool? isFirst;
  final bool? showEndPadding;
  final String name;
  final int propertyCount;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HelperUtils.share(context, agent.id, agent.name);
      },
      onTap: () {
        GuestChecker.check(
          onNotGuest: () async {
            try {
              unawaited(Widgets.showLoader(context));
              await context
                  .read<FetchAgentsPropertyCubit>()
                  .fetchAgentsProperty(
                    agentId: agent.id,
                    forceRefresh: true,
                    isAdmin: agent.isAdmin,
                  );
              final state = context.read<FetchAgentsPropertyCubit>().state;

              if (state is FetchAgentsPropertySuccess) {
                Widgets.hideLoder(context);
                await Navigator.pushNamed(
                  context,
                  Routes.agentDetailsScreen,
                  arguments: {
                    'agent': state.agentsProperty.customerData,
                    'isAdmin': agent.isAdmin,
                  },
                );
              } else {
                if ((agent.id.toString() == HiveUtils.getUserId()) &&
                    state is FetchAgentsPropertySuccess) {
                  Widgets.hideLoder(context);
                  await Navigator.pushNamed(
                    context,
                    Routes.agentDetailsScreen,
                    arguments: {
                      'agent': state.agentsProperty.customerData,
                      'isAdmin': agent.isAdmin,
                    },
                  );
                }
              }
            } catch (e) {
              Widgets.hideLoder(context);
            }
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: context.color.secondaryColor,
          border: Border.all(
            width: 1.5,
            color: context.color.borderColor,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        width: 155,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                clipBehavior: Clip.antiAlias,
                child: UiUtils.getImage(
                  agent.profile,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: CustomText(
                            agent.name.firstUpperCase(),
                            fontWeight: FontWeight.bold,
                            fontSize: context.font.normal,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(
                          width: 2,
                        ),
                        if (agent.isVerified)
                          UiUtils.getSvg(
                            AppIcons.agentBadge,
                            height: 24,
                            width: 24,
                            color: context.color.tertiaryColor,
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    CustomText(
                      '${'properties'.translate(context)}(${agent.propertyCount})',
                      fontSize: context.font.normal,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
            // ),
          ],
        ),
      ),
    );
  }
}
