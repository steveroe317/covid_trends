import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
import '../theme/size_scale.dart';
import 'metric_formatter.dart';
import 'ui_colors.dart';
import 'ui_constants.dart';
import 'ui_parameters.dart';

enum CovidEntityListItemDepth { root, stem, leaf }

class CovidEntityListItem extends StatelessWidget {
  final List<String> _path;
  final CovidEntityListItemDepth _depth;
  final void Function(CovidTimeseriesModel, List<String>) _onRegionPressed;
  final CovidTimeseriesModel _timeseriesModel;
  final CovidEntitiesPageModel _pageModel;
  final numberFormatter;

  CovidEntityListItem(this._path, this._depth, this._onRegionPressed,
      this._pageModel, this._timeseriesModel, this.numberFormatter);

  void onRegionPressed() {
    return _onRegionPressed(_timeseriesModel, _path);
  }

  @override
  build(BuildContext context) {
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);
    var uiParameters = context.read<UiParameters>();
    return Container(
        width: uiParameters.entityRowWidth,
        color: listEquals(_path, pageModel.chartPath())
            ? UiColors.entityListSelected
            : null,
        padding: EdgeInsets.only(left: 0, right: SizeScale.px12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Opacity(
              opacity: (_depth != CovidEntityListItemDepth.root &&
                      _timeseriesModel.entityHasChildren(_path))
                  ? 1.0
                  : 0.0,
              child: IconButton(
                  icon: Icon(_depth == CovidEntityListItemDepth.leaf
                      ? Icons.expand_more
                      : Icons.expand_less),
                  onPressed: (_depth == CovidEntityListItemDepth.stem)
                      ? _openParentPath
                      : (_depth == CovidEntityListItemDepth.leaf &&
                              _timeseriesModel.entityHasChildren(_path))
                          ? _openPath
                          : null),
            ),
            SizedBox(
              width: uiParameters.entityButtonWidth,
              child: TextButton(
                onPressed: onRegionPressed,
                onLongPress: onRegionLongPress,
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(UiColors.darkGreyText),
                    alignment: AlignmentDirectional(0, 0)),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _path.last,
                      style: uiParameters.entityButtonTextStyle,
                    )),
              ),
            ),
            Container(
              width: uiParameters.entityMetricWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(_metricValueString(),
                    style: uiParameters.entityMetricTextStyle),
              ),
            ),
          ],
        ));
  }

  void onRegionLongPress() {
    _pageModel.clearComparisonPathList();
    onRegionPressed();
  }

  void _openParentPath() {
    _pageModel.setEntityPagePath(_path.sublist(0, _path.length - 1));
  }

  void _openPath() {
    _timeseriesModel.loadEntity(_path);
    _pageModel.setEntityPagePath(_path);
  }

  String _metricValueString() {
    String displayMetric = _pageModel.sortMetric;
    if (displayMetric == UiConstants.noSortMetricName) {
      displayMetric = UiConstants.defaultDisplayMetric;
    }
    var metricValue = _timeseriesModel.entitySortMetric(
        _path, displayMetric, _pageModel.per100k);
    var numberFormatter = (_pageModel.per100k)
        ? MetricFormatter.doubleFormatter(metricValue.abs(), graphScale: false)
        : MetricFormatter.integerFormatter;
    return numberFormatter.format(metricValue);
  }
}
