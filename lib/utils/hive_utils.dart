import 'dart:developer';

import 'package:ebroker/app/app_theme.dart';
import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/model/user_model.dart';
import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/hive_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class HiveUtils {
  HiveUtils._();

  static dynamic initBoxes() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(HiveKeys.authBox);
    await Hive.openBox<dynamic>(HiveKeys.userDetailsBox);
    await Hive.openBox<dynamic>(HiveKeys.languageBox);
    await Hive.openBox<dynamic>(HiveKeys.themeBox);
    await Hive.openBox<dynamic>(HiveKeys.svgBox);
    await Hive.openBox<dynamic>(HiveKeys.themeColorBox);
  }

  static String? getJWT() {
    return Hive.box<dynamic>(HiveKeys.userDetailsBox)
            .get(HiveKeys.jwtToken)
            ?.toString() ??
        '';
  }

  static void dontShowChooseLocationDialoge() {
    Hive.box<dynamic>(HiveKeys.userDetailsBox)
        .put('showChooseLocationDialoge', false);
  }

  static bool isGuest() {
    return Hive.box<dynamic>(HiveKeys.userDetailsBox).get('isGuest') as bool? ??
        true;
  }

  static void setAppThemeSetting(Map<String, dynamic> data) {
    Hive.box<dynamic>(HiveKeys.themeColorBox).putAll(data);
  }

  static Map<String, dynamic> getAppThemeSettings() {
    return Map<String, dynamic>.from(
      Hive.box<dynamic>(HiveKeys.themeColorBox).toMap(),
    );
  }

  static void setIsNotGuest() {
    Hive.box<dynamic>(HiveKeys.userDetailsBox).put('isGuest', false);
  }

  static void setIsGuest() {
    Hive.box<dynamic>(HiveKeys.userDetailsBox).put('isGuest', true);
  }

  static bool isShowChooseLocationDialoge() {
    final value = Hive.box<dynamic>(HiveKeys.userDetailsBox).get(
      'showChooseLocationDialoge',
    );

    if (value == null) {
      return true;
    }
    return false;
  }

  static String? getUserId() {
    if (Hive.box<dynamic>(HiveKeys.userDetailsBox).get('id') == null) {
      return null;
    }
    return Hive.box<dynamic>(HiveKeys.userDetailsBox).get('id').toString();
  }

  static AppTheme getCurrentTheme() {
    final current =
        Hive.box<dynamic>(HiveKeys.themeBox).get(HiveKeys.currentTheme);

    if (current == null) {
      return AppTheme.light;
    }
    if (current == 'light') {
      return AppTheme.light;
    }
    if (current == 'dark') {
      return AppTheme.dark;
    }
    return AppTheme.light;
  }

  static dynamic getCountryCode() {
    return Hive.box<dynamic>(HiveKeys.userDetailsBox).toMap()['countryCode'];
  }

  static dynamic getLatitude() {
    return Hive.box<dynamic>(HiveKeys.userDetailsBox).get(HiveKeys.latitude);
  }

  static dynamic getLongitude() {
    return Hive.box<dynamic>(HiveKeys.userDetailsBox).get(HiveKeys.longitude);
  }

  static dynamic getRadius() {
    return Hive.box<dynamic>(HiveKeys.userDetailsBox).get(HiveKeys.radius);
  }

  static Future<void> setProfileNotCompleted() async {
    await Hive.box<dynamic>(HiveKeys.userDetailsBox)
        .put(HiveKeys.isProfileCompleted, false);
  }

  static void setCurrentTheme(AppTheme theme) {
    String newTheme;
    if (theme == AppTheme.light) {
      newTheme = 'light';
    } else {
      newTheme = 'dark';
    }
    Hive.box<dynamic>(HiveKeys.themeBox).put(HiveKeys.currentTheme, newTheme);
  }

  static Future<void> setUserData(Map<dynamic, dynamic> data) async {
    await Hive.box<dynamic>(HiveKeys.userDetailsBox).putAll(data);
  }

  static LoginType getUserLoginType() {
    return LoginType.values.firstWhere(
      (element) =>
          element.name ==
          Hive.box<dynamic>(HiveKeys.userDetailsBox).get('type'),
    );
  }

  static dynamic getCityName() {
    return Hive.box<dynamic>(HiveKeys.userDetailsBox).get(HiveKeys.city);
  }

  static dynamic getCityPlaceId() {
    return Hive.box<dynamic>(HiveKeys.userDetailsBox).get(HiveKeys.cityPlaceId);
  }

  static dynamic getStateName() {
    return Hive.box<dynamic>(HiveKeys.userDetailsBox).get(HiveKeys.stateKey);
  }

  static dynamic getCountryName() {
    return Hive.box<dynamic>(HiveKeys.userDetailsBox).get(HiveKeys.countryKey);
  }

  static Future<void> setJWT(String token) async {
    await Hive.box<dynamic>(HiveKeys.userDetailsBox)
        .put(HiveKeys.jwtToken, token);
  }

  static UserModel getUserDetails() {
    return UserModel.fromJson(
      Map<String, dynamic>.from(
        Hive.box<dynamic>(HiveKeys.userDetailsBox).toMap(),
      ),
    );
  }

  static void setUserIsAuthenticated() {
    Hive.box<dynamic>(HiveKeys.authBox).put(HiveKeys.isAuthenticated, true);
  }

  static Future<void> setUserIsNotAuthenticated() async =>
      Hive.box<dynamic>(HiveKeys.authBox).put(HiveKeys.isAuthenticated, false);

  static Future<void> setUserIsNotNew() {
    Hive.box<dynamic>(HiveKeys.authBox).put(HiveKeys.isAuthenticated, true);
    return Hive.box<dynamic>(HiveKeys.authBox)
        .put(HiveKeys.isUserFirstTime, false);
  }

  static bool isLocationFilled() {
    final city = Hive.box<dynamic>(HiveKeys.userDetailsBox).get(HiveKeys.city);
    final state =
        Hive.box<dynamic>(HiveKeys.userDetailsBox).get(HiveKeys.stateKey);
    final country =
        Hive.box<dynamic>(HiveKeys.userDetailsBox).get(HiveKeys.countryKey);

    if (city == null && state == null && country == null) {
      return false;
    } else {
      return true;
    }
  }

  static Future<void> setLocation({
    required String city,
    required String state,
    required String? latitude,
    required String? longitude,
    required String country,
    required String placeId,
    required String? radius,
  }) async {
    try {
      await Hive.box<dynamic>(HiveKeys.userDetailsBox).put(HiveKeys.city, city);
      await Hive.box<dynamic>(HiveKeys.userDetailsBox)
          .put(HiveKeys.stateKey, state);
      await Hive.box<dynamic>(HiveKeys.userDetailsBox)
          .put(HiveKeys.countryKey, country);

      if (latitude != null) {
        await Hive.box<dynamic>(HiveKeys.userDetailsBox)
            .put(HiveKeys.latitude, latitude);
      }
      if (longitude != null) {
        await Hive.box<dynamic>(HiveKeys.userDetailsBox)
            .put(HiveKeys.longitude, longitude);
      }
      if (radius != null) {
        await Hive.box<dynamic>(HiveKeys.userDetailsBox)
            .put(HiveKeys.radius, radius);
      }
    } catch (e) {
      e.toString().log('issue here is');
    }
  }

  static Future<void> clearLocation() async {
    await Hive.box<dynamic>(HiveKeys.userDetailsBox).putAll({
      HiveKeys.city: '',
      HiveKeys.stateKey: '',
      HiveKeys.countryKey: '',
      HiveKeys.latitude: '',
      HiveKeys.longitude: '',
      HiveKeys.radius: AppSettings.minRadius,
    });
  }

  static Future<bool> storeLanguage(
    data,
  ) async {
    await Hive.box<dynamic>(HiveKeys.languageBox)
        .put(HiveKeys.currentLanguageKey, data);
    // ..put("language", data);
    return true;
  }

  static dynamic getLanguage() {
    return Hive.box<dynamic>(HiveKeys.languageBox)
        .get(HiveKeys.currentLanguageKey);
  }

  @visibleForTesting
  static Future<void> setUserIsNew() {
    //Only testing purpose // not in production
    Hive.box<dynamic>(HiveKeys.authBox).put(HiveKeys.isAuthenticated, false);
    return Hive.box<dynamic>(HiveKeys.authBox)
        .put(HiveKeys.isUserFirstTime, true);
  }

  static bool isUserAuthenticated() {
    //log(Hive.box(HiveKeys.authBox).toMap().toString());
    log('Auth box ${Hive.box<dynamic>(HiveKeys.authBox).toMap()}');
    return Hive.box<dynamic>(HiveKeys.authBox).get(HiveKeys.isAuthenticated)
            as bool? ??
        false;
  }

  static bool isUserFirstTime() {
    return Hive.box<dynamic>(HiveKeys.authBox).get(HiveKeys.isUserFirstTime)
            as bool? ??
        true;
  }

  static Future<void> logoutUser(
    BuildContext context, {
    required VoidCallback onLogout,
    bool? isRedirect,
  }) async {
    try {
      final L = HiveUtils.getUserLoginType();
      if (L == LoginType.email) {
        await AuthRepository().beforeLogout();
        await FirebaseAuth.instance.signOut();
        await setUserIsNotAuthenticated();
        await Hive.box<dynamic>(HiveKeys.userDetailsBox).clear();
        onLogout.call();
        await HiveUtils.setUserIsNotAuthenticated();
        await HiveUtils.clear();
      }
      if (L == LoginType.phone &&
          AppSettings.otpServiceProvider == 'firebase') {
        await AuthRepository().beforeLogout();
        await FirebaseAuth.instance.signOut();
        await setUserIsNotAuthenticated();
        await Hive.box<dynamic>(HiveKeys.userDetailsBox).clear();
        onLogout.call();
        await HiveUtils.setUserIsNotAuthenticated();
        await HiveUtils.clear();
      }
      if (L == LoginType.apple || L == LoginType.google) {
        await AuthRepository().beforeLogout();
        await FirebaseAuth.instance.signOut();
        await setUserIsNotAuthenticated();
        await Hive.box<dynamic>(HiveKeys.userDetailsBox).clear();
        onLogout.call();
        await HiveUtils.setUserIsNotAuthenticated();
        await HiveUtils.clear();
      }
      if (L == LoginType.phone && AppSettings.otpServiceProvider == 'twilio') {
        await setUserIsNotAuthenticated();
        await Hive.box<dynamic>(HiveKeys.userDetailsBox).clear();
        onLogout.call();
        await HiveUtils.setUserIsNotAuthenticated();
        await HiveUtils.clear();
      }
      await Future.delayed(
        Duration.zero,
        () {
          if (isRedirect ?? true) {
            Navigator.pushReplacementNamed(context, Routes.login);
          }
        },
      );
    } catch (e) {
      e.toString().log('issue here is');
      await Future.delayed(
        Duration.zero,
        () {
          if (isRedirect ?? true) {
            Navigator.pushReplacementNamed(context, Routes.login);
          }
        },
      );
    }
  }

  static Future<void> clear() async {
    await Hive.box<dynamic>(HiveKeys.userDetailsBox).clear();
  }
}
