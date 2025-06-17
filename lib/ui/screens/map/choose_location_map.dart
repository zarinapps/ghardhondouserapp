// ignore_for_file: depend_on_referenced_packages, avoid_dynamic_calls

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:ebroker/data/cubits/fetch_home_page_data_cubit.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChooseLocationMap extends StatefulWidget {
  const ChooseLocationMap({
    super.key,
    this.from,
  });
  final String? from;
  static Route<dynamic> route(RouteSettings settings) {
    final arguments = settings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (context) {
        return ChooseLocationMap(
          from: arguments?['from'] as String? ?? '',
        );
      },
    );
  }

  @override
  State<ChooseLocationMap> createState() => _ChooseLocationMapState();
}

class _ChooseLocationMapState extends State<ChooseLocationMap> {
  late String _darkMapStyle;
  double radius =
      double.parse(HiveUtils.getRadius() as String? ?? AppSettings.minRadius);
  var isFirstTime = true;
  Set<Circle> circles = {};
  final TextEditingController _searchController = TextEditingController();
  late WebViewController controllerGlobal;
  String previouseSearchQuery = '';
  LatLng? citylatLong;
  Timer? _timer;
  Marker? marker;
  Map<dynamic, dynamic> map = {};
  Completer<GoogleMapController> completer = Completer<GoogleMapController>();
  GoogleMapController? _googleMapController;
  final FocusNode _searchFocus = FocusNode();
  List<GooglePlaceModel>? cities;
  int selectedMarker = 999999999999999;
  int? propertyId;
  ValueNotifier<bool> isLoadingProperty = ValueNotifier<bool>(false);
  ValueNotifier<bool> loadintCitiesInProgress = ValueNotifier<bool>(false);
  bool showGoogleMap = false;
  Future<void> searchDelayTimer() async {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }

    _timer = Timer(
      const Duration(milliseconds: 500),
      () async {
        if (_searchController.text.isNotEmpty) {
          if (previouseSearchQuery != _searchController.text) {
            try {
              loadintCitiesInProgress.value = true;
              cities = await GooglePlaceRepository().serchCities(
                _searchController.text,
              );
              loadintCitiesInProgress.value = false;
            } catch (e) {
              loadintCitiesInProgress.value = false;
            }

            setState(() {});
            previouseSearchQuery = _searchController.text;
          }
        } else {
          cities = null;
        }
      },
    );
    setState(() {});
  }

  late var assigned = LatLng(
    double.parse(AppSettings.latitude),
    double.parse(AppSettings.longitude),
  );
  late LatLng cameraPosition = assigned;

  Future<void> setCurrentLocation() async {
    try {
      final locationPermission = await Geolocator.checkPermission();
      if (locationPermission == LocationPermission.denied) {
        await Geolocator.requestPermission();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final controller = await completer.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 7,
          ),
        ),
      );

      marker = Marker(
        markerId: const MarkerId('9999999'),
        position: LatLng(position.latitude, position.longitude),
      );

      setState(() {});
    } catch (e) {
      debugPrint('Error in setCurrentLocation: $e');
    }
  }

  @override
  void initState() {
    _loadMapStyles();
    _searchController.addListener(searchDelayTimer);
    if (AppSettings.latitude == '' || AppSettings.longitude == '') {
      marker = Marker(markerId: const MarkerId('9999999'), position: assigned);

      setState(() {});
    } else {
      setCurrentLocation();
    }
    Future.delayed(
      const Duration(milliseconds: 500),
      () {
        showGoogleMap = true;
        setState(() {});
      },
    );

    super.initState();
  }

  Future<void> _loadMapStyles() async {
    _darkMapStyle =
        await rootBundle.loadString('assets/map_styles/dark_map.json');
  }

  Future<void> onTapCity(int index) async {
    try {
      final latLng = await getCityLatLong(index);

      if (latLng != null) {
        final controller = await completer.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: latLng, zoom: 7),
          ),
        );

        marker = Marker(
          markerId: MarkerId(index.toString()),
          position: latLng,
        );

        _searchFocus.unfocus();
        HelperUtils.unfocus();

        cities = null;
        setState(() {});
        Widgets.hideLoder(context);
      }
    } catch (e) {
      debugPrint('Error in onTapCity: $e');
    } finally {
      Widgets.hideLoder(context);
    }
  }

  Future<LatLng?>? getCityLatLong(index) async {
    final rawCityLatLong =
        await GooglePlaceRepository().getPlaceDetailsFromPlaceId(
      cities?.elementAt(index as int).placeId ?? '',
    );

    final citylatLong = LatLng(
      rawCityLatLong['lat'] as double,
      rawCityLatLong['lng'] as double,
    );
    return citylatLong;
  }

  @override
  Future<void> dispose() async {
    _searchController.removeListener(searchDelayTimer);
    _timer?.cancel();
    if (_googleMapController != null) {
      _googleMapController!.dispose();
    }
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  String? getComponent(List<dynamic> data, dm) {
    // log("CALLED");
    try {
      return data
          .where((element) {
            return (element['types'] as List).contains(dm);
          })
          .first['long_name']
          ?.toString();
    } catch (e) {
      return null;
    }
  }

  Widget buildSearchIcon() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: UiUtils.getSvg(
        AppIcons.search,
        color: context.color.tertiaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.from == 'home_location' && isFirstTime) {
      isFirstTime = false;
      if (HiveUtils.getLatitude() != '' &&
          HiveUtils.getLongitude() != '' &&
          HiveUtils.getLatitude() != null &&
          HiveUtils.getLongitude() != null) {
        _addCircle(
          LatLng(
            double.parse(HiveUtils.getLatitude().toString()),
            double.parse(HiveUtils.getLongitude().toString()),
          ),
          radius,
        );
      }
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_googleMapController != null) {
          _googleMapController!.dispose();
        }
        showGoogleMap = false;
        setState(() {});

        Future.delayed(Duration.zero, () {
          Navigator.of(context).pop();
        });
      },
      child: Scaffold(
        backgroundColor: context.color.secondaryColor,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.from == 'home_location') buildRadiusSelector(),
            SizedBox(
              child: UiUtils.buildButton(
                context,
                height: 45.rh(context),
                radius: 10,
                outerPadding: const EdgeInsets.only(
                  right: 16,
                  left: 16,
                  bottom: 8,
                  top: 8,
                ),
                onPressed: marker == null
                    ? () {
                        HelperUtils.showSnackBarMessage(
                          context,
                          'pleaseSelectLocation'.translate(context),
                          messageDuration: 5,
                        );
                      }
                    : () async {
                        try {
                          String? state = '';
                          String? city = '';
                          String? country = '';
                          String? sublocality = '';
                          String? pointofinterest = '';
                          final response = await Dio().get<dynamic>(
                            'https://maps.googleapis.com/maps/api/geocode/json?key=${Constant.googlePlaceAPIkey}&latlng=${marker?.position.latitude},${marker?.position.longitude}',
                          );

                          if ((response.data as Map)
                              .containsKey('error_message')) {
                            log(response.data?.toString() ?? '');
                          }
                          final component = List<dynamic>.from(
                            response.data['results'][0]['address_components']
                                    as List? ??
                                [],
                          );

                          city = getComponent(
                            component,
                            'locality',
                          );
                          state = getComponent(
                            component,
                            'administrative_area_level_1',
                          );
                          country = getComponent(component, 'country');
                          sublocality = getComponent(component, 'sublocality');

                          pointofinterest =
                              getComponent(component, 'point_of_interest');

                          final startsWith = pointofinterest?.contains(',');
                          if (startsWith ?? false) {
                            pointofinterest =
                                pointofinterest?.replaceFirst(',', '');
                          }

                          final place = Placemark(
                            locality: city,
                            administrativeArea: state,
                            country: country,
                            subLocality: sublocality,
                            street: pointofinterest,
                          );

                          showGoogleMap = false;

                          setState(() {});

                          Future.delayed(
                            Duration.zero,
                            () async {
                              await HiveUtils.setLocation(
                                city: place.locality.toString(),
                                state: place.administrativeArea.toString(),
                                latitude: marker!.position.latitude.toString(),
                                longitude:
                                    marker!.position.longitude.toString(),
                                country: place.country.toString(),
                                placeId:
                                    HiveUtils.getCityPlaceId()?.toString() ??
                                        '',
                                radius: radius.toString(),
                              );

                              Navigator.pop<Map<dynamic, dynamic>>(context, {
                                'latlng': LatLng(
                                  marker!.position.latitude,
                                  marker!.position.longitude,
                                ),
                                'place': place,
                                if (widget.from == 'home_location')
                                  'radius': radius.toString(),
                              });
                              if (widget.from == 'home_location') {
                                await context
                                    .read<FetchHomePageDataCubit>()
                                    .fetch(
                                      forceRefresh: true,
                                    );
                              }
                            },
                          );
                        } catch (e) {
                          if (e is Map) {
                            if (e.containsKey('error_message')) {
                              await HelperUtils.showSnackBarMessage(
                                context,
                                e['error_message']?.toString() ?? '',
                                messageDuration: 5,
                              );
                            }
                          }

                          if (e.toString().contains('IO_ERROR')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: CustomText(
                                  'pleaseChangeNetwork'.translate(context),
                                ),
                              ),
                            );
                          }
                        }
                      },
                buttonTitle: widget.from == 'home_location'
                    ? 'apply'.translate(context)
                    : 'proceed'.translate(context),
              ),
            ),
          ],
        ),
        appBar: AppBar(
          toolbarHeight: 65.rh(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          titleSpacing: 0,
          leading: cities != null
              ? GestureDetector(
                  onTap: () {
                    cities = null;
                    _searchController.text = '';
                    setState(() {});
                  },
                  child: Icon(
                    Icons.close,
                    color: context.color.tertiaryColor,
                  ),
                )
              : Material(
                  clipBehavior: Clip.antiAlias,
                  color: Colors.transparent,
                  type: MaterialType.circle,
                  child: GestureDetector(
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
          title: Container(
            alignment: Alignment.center,
            margin:
                const EdgeInsetsDirectional.only(top: 8, end: 10, bottom: 8),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1.5,
                color: context.color.borderColor,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: context.color.secondaryColor,
            ),
            child: TextFormField(
              focusNode: _searchFocus,
              controller: _searchController,
              style: TextStyle(
                color: context.color.textColorDark,
              ),
              decoration: InputDecoration(
                labelStyle: TextStyle(
                  color: context.color.textColorDark,
                ),

                hintStyle: TextStyle(
                  color: context.color.textColorDark.withValues(alpha: 0.7),
                ),
                border: InputBorder.none, //OutlineInputBorder()
                fillColor: Theme.of(context).colorScheme.secondaryColor,
                hintText: UiUtils.translate(context, 'searhCity'),
                prefixIcon: buildSearchIcon(),
                prefixIconConstraints:
                    const BoxConstraints(minHeight: 5, minWidth: 5),
              ),
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              onTap: () {
                //change prefix icon color to primary
              },
            ),
          ),
        ),
        body: Stack(
          children: [
            SizedBox(
              height: context.screenHeight,
              width: context.screenWidth,
              child: showGoogleMap == true
                  ? GoogleMap(
                      style: context.color.brightness == Brightness.dark
                          ? _darkMapStyle
                          : null,
                      markers: marker == null ? {} : {marker!},
                      circles: circles,
                      onCameraMove: (position) =>
                          FocusScope.of(context).unfocus(),
                      onMapCreated: (GoogleMapController controller) {
                        if (!completer.isCompleted) {
                          completer.complete(controller);
                          _googleMapController = controller;
                        }
                        setState(() {});
                      },
                      onTap: (argument) async {
                        selectedMarker = 99999999999999;
                        cameraPosition = LatLng(
                          argument.latitude,
                          argument.longitude,
                        );
                        marker = Marker(
                          markerId: const MarkerId('0'),
                          position: cameraPosition,
                        );
                        _addCircle(
                          LatLng(
                            marker!.position.latitude,
                            marker!.position.longitude,
                          ),
                          radius,
                        );

                        setState(() {});
                      },
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      trafficEnabled: true,
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                      initialCameraPosition:
                          CameraPosition(target: cameraPosition, zoom: 7),
                      key: const Key('G-map'),
                    )
                  : const SizedBox.shrink(),
            ),
            if (cities != null)
              ColoredBox(
                color: context.color.backgroundColor,
                child: ListView.builder(
                  itemCount: cities?.length ?? 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () async {
                        setState(() {});
                        await onTapCity(index);
                      },
                      leading: SvgPicture.asset(
                        AppIcons.location,
                        colorFilter: ColorFilter.mode(
                          context.color.textColorDark,
                          BlendMode.srcIn,
                        ),
                      ),
                      title: CustomText(cities?.elementAt(index).city ?? ''),
                      subtitle: Text.rich(
                        TextSpan(
                          text: cities?.elementAt(index).state ?? '',
                          children: [
                            if (cities?.elementAt(index).country != '')
                              TextSpan(
                                text:
                                    ',${cities?.elementAt(index).country ?? ''}',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ValueListenableBuilder(
              valueListenable: loadintCitiesInProgress,
              builder: (context, value, child) {
                if (cities == null && loadintCitiesInProgress.value == true) {
                  return ColoredBox(
                    color: context.color.backgroundColor,
                    child: Center(
                      child: UiUtils.progress(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRadiusSelector() {
    final distanceOption = context
        .read<FetchSystemSettingsCubit>()
        .getSetting(SystemSetting.distanceOption);
    final minRadius = double.parse(
      AppSettings.minRadius.isEmpty ? '1' : AppSettings.minRadius,
    );
    return Container(
      color: context.color.secondaryColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                'selectAreaRange'.translate(context),
                color: context.color.textColorDark,
                fontSize: context.font.large,
                fontWeight: FontWeight.w500,
              ),
              CustomText(
                '${radius.toInt()} $distanceOption',
                color: context.color.textColorDark,
                fontSize: context.font.normal,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Slider(
            value: radius < minRadius ? minRadius : radius,
            padding: EdgeInsets.zero,
            min: double.parse(AppSettings.minRadius),
            max: double.parse(AppSettings.maxRadius),
            activeColor: context.color.textColorDark,
            inactiveColor: context.color.textLightColor.withValues(alpha: 0.1),
            divisions: (double.parse(AppSettings.maxRadius) -
                    double.parse(AppSettings.minRadius))
                .toInt(),
            label: '${radius.toInt()} $distanceOption',
            onChanged: (value) {
              radius = value;
              setState(() {
                _addCircle(
                  LatLng(marker!.position.latitude, marker!.position.longitude),
                  radius,
                );
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                '${AppSettings.minRadius} $distanceOption',
                color: context.color.textColorDark,
                fontSize: context.font.normal,
                fontWeight: FontWeight.w400,
              ),
              CustomText(
                '${AppSettings.maxRadius} $distanceOption',
                color: context.color.textColorDark,
                fontSize: context.font.normal,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addCircle(LatLng position, double radiusInKm) {
    final radiusInMeters = radiusInKm * 1000; // Convert km to meters

    setState(() {
      circles
        ..clear() // Clear any existing circles
        ..add(
          Circle(
            circleId: const CircleId('searchRadius'),
            center: position,
            radius: radiusInMeters,
            fillColor: context.color.tertiaryColor.withValues(alpha: .2),
            strokeWidth: 1,
            strokeColor: context.color.tertiaryColor,
          ),
        );
    });
  }
}
