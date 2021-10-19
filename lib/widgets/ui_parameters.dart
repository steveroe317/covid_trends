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

import '../theme/palette_colors.dart';
import '../theme/size_scale.dart';

import 'ui_constants.dart';

enum UiAppShape { Wide, Narrow, Mini }

class UiParameters with ChangeNotifier {
  UiAppShape _uiShape;
  var _entityButtonWidth = 170.0;
  var _entityMetricWidth = 120.0;
  var _starredButtonWidth = 290.0;
  var _drawerHeaderHeight = 75.0;

  var _entityButtonTextStyle = TextStyle(
      color: PaletteColors.coolGrey.shade900,
      fontSize: SizeScale.px20,
      fontWeight: FontWeight.w500);

  var _entityMetricTextStyle = TextStyle(
      color: PaletteColors.coolGrey.shade900,
      fontSize: SizeScale.px14,
      fontWeight: FontWeight.w400);

  UiParameters(UiAppShape shape) : _uiShape = shape {
    if (uiShape == UiAppShape.Mini) {
      _entityButtonWidth = 140.0;
      _entityMetricWidth = 120.0;
      _starredButtonWidth = 260.0;
      _entityButtonTextStyle = TextStyle(
          color: PaletteColors.coolGrey.shade900,
          fontSize: SizeScale.px16,
          fontWeight: FontWeight.w500);
    }
  }

  UiAppShape get uiShape => _uiShape;

  double get entityButtonWidth => _entityButtonWidth;
  double get entityMetricWidth => _entityMetricWidth;
  double get starredButtonWidth => _starredButtonWidth;
  double get drawerHeaderHeight => _drawerHeaderHeight;
  TextStyle get entityButtonTextStyle => _entityButtonTextStyle;
  TextStyle get entityMetricTextStyle => _entityMetricTextStyle;

  double get entityRowWidth =>
      entityButtonWidth + entityMetricWidth + UiConstants.iconWidth + 24 + 12;
}
