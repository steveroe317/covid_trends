import 'package:flutter/material.dart';

import '../theme/palette_colors.dart';
import '../theme/size_scale.dart';

import 'ui_constants.dart';

enum UiAppShape { Wide, Narrow, Mini }

class UiParameters with ChangeNotifier {
  UiAppShape _uiShape;
  var _entityButtonWidth = 170.0;
  var _entityMetricWidth = 120.0;
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
      _entityButtonTextStyle = TextStyle(
          color: PaletteColors.coolGrey.shade900,
          fontSize: SizeScale.px16,
          fontWeight: FontWeight.w500);
    }
  }

  UiAppShape get uiShape => _uiShape;

  double get entityButtonWidth => _entityButtonWidth;
  double get entityMetricWidth => _entityMetricWidth;
  double get drawerHeaderHeight => _drawerHeaderHeight;
  TextStyle get entityButtonTextStyle => _entityButtonTextStyle;
  TextStyle get entityMetricTextStyle => _entityMetricTextStyle;

  double get entityRowWidth =>
      entityButtonWidth + entityMetricWidth + UiConstants.iconWidth + 24 + 12;
}
