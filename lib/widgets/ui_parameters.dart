import 'ui_constants.dart';

enum UiAppShape { Wide, Narrow, Mini }

class UiParameters {
  UiAppShape _uiShape;
  var _entityButtonWidth = 170.0;
  var _entityMetricWidth = 120.0;

  UiParameters(UiAppShape shape) {
    _uiShape = shape;
    if (uiShape == UiAppShape.Mini) {
      _entityButtonWidth = 150.0;
      _entityMetricWidth = 110.0;
    }
  }

  UiAppShape get uiShape => _uiShape;

  double get entityButtonWidth => _entityButtonWidth;
  double get entityMetricWidth => _entityMetricWidth;

  double get entityRowWidth =>
      entityButtonWidth + entityMetricWidth + UiConstants.iconWidth + 24 + 12;
}
