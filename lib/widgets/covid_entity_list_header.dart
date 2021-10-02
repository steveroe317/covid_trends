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
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
import '../theme/size_scale.dart';
import 'ui_colors.dart';
import 'ui_constants.dart';
import 'ui_parameters.dart';

class CovidEntityListHeader extends StatelessWidget {
  final CovidEntitiesPageModel _pageModel;
  final CovidTimeseriesModel _timeseriesModel;

  CovidEntityListHeader(this._pageModel, this._timeseriesModel);

  @override
  build(BuildContext context) {
    var uiParameters = context.read<UiParameters>();
    return Container(
        width: uiParameters.entityRowWidth,
        padding: EdgeInsets.only(left: 0, right: SizeScale.px12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _pageModel.entitySearchActive = true;
              },
            ),
            SizedBox(
              width: uiParameters.entityButtonWidth,
              child: TextButton(
                onPressed: null,
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(UiColors.darkGreyText),
                    alignment: AlignmentDirectional(0, 0)),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Region',
                      style: uiParameters.entityButtonTextStyle,
                    )),
              ),
            ),
            Container(
              width: uiParameters.entityMetricWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _sortMetricName(),
                  style: uiParameters.entityMetricTextStyle,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ));
  }

  String _sortMetricName() {
    var name = UiConstants.metricIdLabel(_pageModel.itemListMetric);
    if (_pageModel.per100k &&
        _timeseriesModel.populationMetrics
            .contains(_pageModel.itemListMetric)) {
      name = '$name\nper 100,000';
    }
    return name;
  }
}
