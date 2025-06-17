import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/cubits/agents/fetch_property_cubit.dart';
import 'package:ebroker/ui/screens/proprties/property_details.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/guest_checker.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgentProfileWidget extends StatefulWidget {
  const AgentProfileWidget({
    required this.widget,
    super.key,
  });

  final PropertyDetails widget;

  @override
  State<AgentProfileWidget> createState() => _AgentProfileWidgetState();
}

class _AgentProfileWidgetState extends State<AgentProfileWidget> {
  bool? isAdmin;
  String? agentID;

  @override
  void initState() {
    super.initState();
    isAdmin = widget.widget.property!.addedBy?.toString() == '0';
    agentID = widget.widget.property!.addedBy?.toString();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchAgentsPropertyCubit, FetchAgentsPropertyState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () async {
            await GuestChecker.check(
              onNotGuest: () async {
                try {
                  await Navigator.pushNamed(
                    context,
                    Routes.agentDetailsScreen,
                    arguments: {
                      'agentID': agentID,
                      'isAdmin': isAdmin,
                    },
                  );
                } catch (_) {}
              },
            );
          },
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: UiUtils.getImage(
                  widget.widget.property?.customerProfile ?? '',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: CustomText(
                            widget.widget.property?.customerName ?? '',
                            fontWeight: FontWeight.bold,
                            fontSize: context.font.large,
                          ),
                        ),
                        if (widget.widget.property?.isVerified ?? false)
                          FittedBox(
                            fit: BoxFit.none,
                            child: UiUtils.getSvg(
                              AppIcons.agentBadge,
                              height: 24,
                              width: 24,
                              color: context.color.tertiaryColor,
                            ),
                          ),
                      ],
                    ),
                    CustomText(widget.widget.property?.customerEmail ?? ''),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
