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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';
import '../models/covid_timeseries_model.dart';
import '../theme/size_scale.dart';
import 'metric_formatter.dart';
import 'ui_colors.dart';
import 'ui_parameters.dart';

enum CovidEntityListItemDepth { root, stem, leaf }

class CovidEntityListItem extends StatelessWidget {
  final List<String> _path;
  final CovidEntityListItemDepth _depth;
  final void Function(CovidTimeseriesModel, List<String>) _onRegionPressed;
  final CovidTimeseriesModel _timeseriesModel;
  final AppDisplayStateModel _pageModel;
  final numberFormatter;

  CovidEntityListItem(this._path, this._depth, this._onRegionPressed,
      this._pageModel, this._timeseriesModel, this.numberFormatter);

  void onRegionPressed() {
    return _onRegionPressed(_timeseriesModel, _path);
  }

  @override
  build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);
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
    _pageModel.setParentPath(_path.sublist(0, _path.length - 1));
  }

  void _openPath() {
    _timeseriesModel.loadEntity(_path);
    _pageModel.setParentPath(_path);
  }

  String _metricValueString() {
    var metricValue = _timeseriesModel.entitySortMetric(
        _path, _pageModel.itemListMetric, _pageModel.per100k);
    var numberFormatter = (_pageModel.per100k)
        ? MetricFormatter.doubleFormatter(metricValue.abs(), graphScale: false)
        : MetricFormatter.integerFormatter;
    return numberFormatter.format(metricValue);
  }
}
