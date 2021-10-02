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

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_series_id.dart';
import '../theme/size_scale.dart';
import 'covid_chart.dart';
import 'covid_chart_page.dart';
import 'ui_constants.dart';

class CovidChartGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= UiConstants.chartTableWidthBreakpoint ||
            constraints.maxHeight <= UiConstants.chartTableHeightBreakpoint ||
            constraints.maxWidth / constraints.maxHeight <
                UiConstants.chartTableAspectRatioBreakpoint) {
          return CovidChartList(constraints.maxHeight);
        } else {
          return CovidChartTable(constraints.maxHeight);
        }
      },
    );
  }
}

class CovidChartList extends StatelessWidget {
  final double constraintsHeight;

  CovidChartList(this.constraintsHeight);

  @override
  Widget build(BuildContext context) {
    var labelledChartHeight =
        max(UiConstants.minCovidChartHeight, constraintsHeight / 4);
    return ListView(
      children: <Widget>[
        _LabelledCovidChart(CovidSeriesId.ConfirmedDaily, labelledChartHeight),
        _LabelledCovidChart(CovidSeriesId.DeathsDaily, labelledChartHeight),
        _LabelledCovidChart(CovidSeriesId.Confirmed, labelledChartHeight),
        _LabelledCovidChart(CovidSeriesId.Deaths, labelledChartHeight),
      ],
    );
  }
}

class CovidChartTable extends StatelessWidget {
  final double constraintsHeight;

  CovidChartTable(this.constraintsHeight);

  @override
  Widget build(BuildContext context) {
    var labelledChartHeight =
        max(UiConstants.minCovidChartHeight, constraintsHeight / 2);
    return Row(
      children: [
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              _LabelledCovidChart(
                  CovidSeriesId.ConfirmedDaily, labelledChartHeight),
              _LabelledCovidChart(
                  CovidSeriesId.DeathsDaily, labelledChartHeight),
            ])),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LabelledCovidChart(CovidSeriesId.Confirmed, labelledChartHeight),
            _LabelledCovidChart(CovidSeriesId.Deaths, labelledChartHeight),
          ],
        )),
      ],
    );
  }
}

class _LabelledCovidChart extends StatelessWidget {
  final CovidSeriesId seriesId;
  final double labelledChartHeight;

  _LabelledCovidChart(this.seriesId, this.labelledChartHeight);

  @override
  build(BuildContext context) {
    final pageModel = Provider.of<CovidEntitiesPageModel>(context);
    final scaleSuffix = (pageModel.per100k) ? ' per 100k' : '';
    var paths = (pageModel.compareRegion)
        ? pageModel.comparisonPathList
        : [pageModel.chartPath()];
    var regionName = (paths.length == 1 && paths.first.length > 0)
        ? '${paths.first.last} '
        : '';

    var seriesName = CovidChart.covidSeriesName(seriesId);
    var title = '$regionName$seriesName$scaleSuffix';
    var titleTextStyle = TextStyle(fontWeight: FontWeight.w600);
    var subtitle = (UiConstants.averagedSeries.contains(seriesId))
        ? UiConstants.averagedSubtitle
        : '';
    var subtitleTextStyle = TextStyle(fontWeight: FontWeight.normal);
    Size titleSize = paintedTextSize(title, titleTextStyle, context);
    Size subtitleSize = paintedTextSize(
        UiConstants.averagedSubtitle, subtitleTextStyle, context);
    var chartHeight = labelledChartHeight -
        (SizeScale.px24 +
            SizeScale.px8 +
            titleSize.height +
            subtitleSize.height +
            SizeScale.px24);

    return Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(
            SizeScale.px24, SizeScale.px24, SizeScale.px24, SizeScale.px8),
        child: SizedBox(
          height: chartHeight,
          child: new CovidChart(seriesId, false),
        ),
      ),
      Padding(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CovidChartPage(seriesId: seriesId)),
              );
            },
            child: Center(child: Text(title, style: titleTextStyle)),
          )),
      Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, SizeScale.px24),
          child: Center(child: Text(subtitle, style: subtitleTextStyle))),
    ]);
  }

  // This code to get the size of a text widget is from
  // https://stackoverflow.com/questions/52659759
  Size paintedTextSize(
      String label, TextStyle labelTextStyle, BuildContext context) {
    final Size titleSize = (TextPainter(
            text: TextSpan(text: label, style: labelTextStyle),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
    return titleSize;
  }
}
