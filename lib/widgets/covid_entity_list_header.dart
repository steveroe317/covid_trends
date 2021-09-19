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
            // This icon is not yet used, but is included to match alignment
            // with CovidEntityListItem.
            Opacity(
              opacity: 0.0,
              child: IconButton(
                icon: Icon(Icons.expand_more),
                onPressed: () {},
              ),
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
                child: Text(_sortMetricName(),
                    style: uiParameters.entityMetricTextStyle),
              ),
            ),
          ],
        ));
  }

  String _sortMetricName() {
    var name = (_pageModel.sortMetric != UiConstants.noSortMetricName)
        ? _pageModel.sortMetric
        : UiConstants.defaultDisplayMetric;
    if (_pageModel.per100k &&
        _timeseriesModel.populationMetrics.contains(name)) {
      name = '$name\nper 100,000';
    }
    return name;
  }
}
