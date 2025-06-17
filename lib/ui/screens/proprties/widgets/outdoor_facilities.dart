import 'package:ebroker/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OutdoorFacilityListWidget extends StatelessWidget {
  const OutdoorFacilityListWidget({
    required this.outdoorFacilityList,
    super.key,
  });
  final List<AssignedOutdoorFacility> outdoorFacilityList;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: outdoorFacilityList.length,
      itemBuilder: (context, index) {
        final facility = outdoorFacilityList[index];
        final distanceOption = context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.distanceOption);
        return Column(
          //crossAxisAlignment: getCrossAxisAlignment(columnIndex),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: context.color.tertiaryColor.withValues(alpha: 0.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: UiUtils.imageType(
                        facility.image ?? '',
                        color: Constant.adaptThemeColorSvg
                            ? context.color.tertiaryColor
                            : null,
                        // fit: BoxFit.cover,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CustomText(
                  facility.name ?? '',
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  fontSize: context.font.small,
                  color: context.color.textColorDark,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: CustomText(
                        '${facility.distance != '0' ? facility.distance : '<1'}  ',
                        fontSize: context.font.small,
                        color: context.color.inverseSurface,
                        maxLines: 1,
                      ),
                    ),
                    Flexible(
                      child: CustomText(
                        '$distanceOption'.firstUpperCase(),
                        fontSize: context.font.small,
                        color: context.color.inverseSurface,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
