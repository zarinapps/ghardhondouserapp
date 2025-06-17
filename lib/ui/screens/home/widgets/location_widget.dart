import 'dart:developer';

import 'package:ebroker/app/app.dart';
import 'package:ebroker/app/routes.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/utils/AppIcon.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:ebroker/utils/hive_keys.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsiveSize.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocationWidget extends StatefulWidget {
  const LocationWidget({super.key});

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String city = '';
  String state = '';
  String country = '';
  late Box<dynamic> userDetailsBox;
  late VoidCallback listener;
  var localLatitude = 0.0;
  var localLongitude = 0.0;

  @override
  void initState() {
    super.initState();
    userDetailsBox = Hive.box(HiveKeys.userDetailsBox);
    listener = () {
      if (mounted) {
        setState(() {
          city = HiveUtils.getCityName().toString().trim();
          state = HiveUtils.getStateName().toString().trim();
          country = HiveUtils.getCountryName().toString().trim();
        });
      }
    };
    userDetailsBox
        .listenable(keys: ['city', 'state', 'country']).addListener(listener);
  }

  @override
  void dispose() {
    userDetailsBox.listenable(
      keys: ['city', 'state', 'country'],
    ).removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    city = HiveUtils.getCityName().toString().trim();
    state = HiveUtils.getStateName().toString().trim();
    country = HiveUtils.getCountryName().toString().trim();

    final locationList = <String>[city, state, country]..removeWhere((element) {
        return element.isEmpty || element == 'null' || element == '';
      });
    final joinedLocation = locationList.join(', ');

    return joinedLocation.isEmpty
        ? Align(
            alignment: AlignmentDirectional.centerStart,
            child: UiUtils.getImage(
              appSettings.appHomeScreen!,
              height: 45.rh(context),
              width: 125.rh(context),
              fit: BoxFit.scaleDown,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  FocusManager.instance.primaryFocus?.unfocus();

                  if (Hive.box<dynamic>(HiveKeys.userDetailsBox)
                      .get('latitude')
                      .toString()
                      .isNotEmpty) {
                    final dynamic latitudeValue =
                        Hive.box<dynamic>(HiveKeys.userDetailsBox)
                                .get('latitude') ??
                            '0';
                    localLatitude =
                        double.tryParse(latitudeValue.toString()) ?? 0.0;
                  }
                  if (Hive.box<dynamic>(HiveKeys.userDetailsBox)
                      .get('longitude')
                      .toString()
                      .isNotEmpty) {
                    final dynamic longitudeValue =
                        Hive.box<dynamic>(HiveKeys.userDetailsBox)
                                .get('longitude') ??
                            '0';
                    localLongitude =
                        double.tryParse(longitudeValue.toString()) ?? 0.0;
                  }

                  final placeMark = await Navigator.pushNamed(
                    context,
                    Routes.chooseLocaitonMap,
                    arguments: {
                      'from': 'home_location',
                    },
                  ) as Map?;
                  try {
                    final latlng = placeMark?['latlng'] as LatLng;
                    final place = placeMark?['place'] as Placemark;
                    final radius = placeMark?['radius']?.toString() ??
                        AppSettings.minRadius;

                    await HiveUtils.setLocation(
                      city: place.locality ?? '',
                      state: place.administrativeArea ?? '',
                      latitude: latlng.latitude.toString(),
                      longitude: latlng.longitude.toString(),
                      country: place.country ?? '',
                      placeId: place.postalCode ?? '',
                      radius: radius,
                    );
                  } catch (e) {
                    log(e.toString());
                  }
                },
                child: Container(
                  width: 40.rw(context),
                  height: 40.rh(context),
                  decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: UiUtils.getSvg(
                    AppIcons.location,
                    fit: BoxFit.none,
                    color: context.color.tertiaryColor,
                  ),
                ),
              ),
              SizedBox(
                width: 10.rw(context),
              ),
              ValueListenableBuilder(
                valueListenable: userDetailsBox.listenable(),
                builder: (context, value, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        UiUtils.translate(context, 'locationLbl'),
                        fontSize: context.font.small,
                        color: context.color.textColorDark,
                      ),
                      SizedBox(
                        width: 150,
                        child: CustomText(
                          joinedLocation,
                          maxLines: 1,
                          fontWeight: FontWeight.w600,
                          fontSize: context.font.small,
                          color: context.color.textColorDark,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
  }
}
