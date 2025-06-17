// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:ebroker/app/app_theme.dart';
import 'package:ebroker/utils/hive_utils.dart';

class AppThemeCubit extends Cubit<ThemeState> {
  AppThemeCubit() : super(ThemeState(AppTheme.light));
// HiveUtils.getCurrentTheme()
  void changeTheme(AppTheme appTheme) {
    HiveUtils.setCurrentTheme(appTheme);
    emit(ThemeState(appTheme));
  }

  //dev!
  void toggleTheme() {
    final newTheme =
        state.appTheme == AppTheme.dark ? AppTheme.light : AppTheme.dark;
    if (state.appTheme == AppTheme.dark) {
      emit(ThemeState(AppTheme.light));
    } else {
      emit(ThemeState(AppTheme.dark));
    }
    HiveUtils.setCurrentTheme(newTheme);
  }

  bool isDarkMode() {
    return state.appTheme == AppTheme.dark;
  }
}

class ThemeState {
  ThemeState(this.appTheme);
  final AppTheme appTheme;
}
