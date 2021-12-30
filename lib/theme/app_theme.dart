// Copyright 2021 Stephen Roe
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.import 'dart:collection';

import 'package:flutter/material.dart';
import 'palette_colors.dart';

class AppTheme {
  late ThemeData themeData;

  AppTheme() {
    themeData = ThemeData.from(
        colorScheme: ColorScheme.fromSwatch(
      primarySwatch: PaletteColors.lightBlueVivid,
    ));
    var navigationRailTheme = NavigationRailThemeData(
        backgroundColor: themeData.colorScheme.primary,
        elevation: themeData.appBarTheme.elevation,
        selectedIconTheme: themeData.iconTheme.copyWith(color: Colors.white),
        unselectedIconTheme:
            themeData.iconTheme.copyWith(color: Colors.grey[400]));
    var navigationBarTheme = BottomNavigationBarThemeData(
      backgroundColor: themeData.colorScheme.primary,
      elevation: themeData.appBarTheme.elevation,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[400],
    );
    themeData = themeData
        .copyWith(backgroundColor: themeData.colorScheme.primary)
        .copyWith(dialogBackgroundColor: Colors.grey[50])
        .copyWith(cardColor: Colors.grey[50])
        .copyWith(navigationRailTheme: navigationRailTheme)
        .copyWith(bottomNavigationBarTheme: navigationBarTheme);
  }
}
