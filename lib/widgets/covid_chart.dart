import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';

class CovidChart extends StatelessWidget {
  final String seriesName;
  // TODO: Use enum to control title rather than bool.
  final bool showTitle;
  final bool animate = true;

  CovidChart(this.seriesName, this.showTitle);

  @override
  Widget build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);
    var seriesLength = pageModel.seriesLength;
    var per100k = pageModel.per100k;
    var paths = (pageModel.compareRegion)
        ? pageModel.comparisonPathList
        : [pageModel.chartPath()];
    var regionName = (paths.length == 1 && paths.first.length > 0)
        ? '${paths.first.last} '
        : '';
    var scaleSuffix = (pageModel.per100k) ? ' per 100k' : '';
    var title = '$regionName$seriesName$scaleSuffix';

    // Get timestamps from the root of the admin entity tree, as it is most
    // likely to have been loaded already.
    var timestamps = timeseriesModel.entityTimestamps(paths[0].sublist(0, 1),
        seriesLength: seriesLength);

    // Build data series for chart.
    var seriesDataList = paths
        .map((path) => timeseriesModel.entitySeriesData(path, seriesName,
            seriesLength: seriesLength, per100k: per100k))
        .toList();
    var seriesList =
        createTimeseries(pageModel, paths, timestamps, seriesDataList);

    // Determine maximum chart data value.
    var dataMaximum = 10.0;
    if (seriesDataList.length > 0) {
      var seriesDataMaximums = seriesDataList.map((dataList) {
        return (dataList.length > 0) ? dataList.reduce(max) : 0.0;
      });
      if (seriesDataMaximums.length > 0)
        dataMaximum = seriesDataMaximums.reduce(max);
    }

    // Add optional tick formatter based on maximum chart data value.
    var numberFormatString = '';
    if (dataMaximum >= 10.0 || dataMaximum == 0.0) {
      numberFormatString = '#0';
    } else if (dataMaximum >= 1.0) {
      numberFormatString = '#0.0';
    } else if (dataMaximum >= 0.1) {
      numberFormatString = '#0.00';
    } else if (dataMaximum >= 0.01) {
      numberFormatString = '#0.000';
    }
    var dataFormatter =
        new charts.BasicNumericTickFormatterSpec.fromNumberFormat(
            new NumberFormat(numberFormatString, 'en_US'));

    // Add optional chart legend and title.
    List<charts.ChartBehavior<DateTime>>? chartBehaviors = [];

    if (pageModel.compareRegion) {
      chartBehaviors.add(new charts.SeriesLegend(
          desiredMaxColumns: 2, cellPadding: const EdgeInsets.all(2.0)));
    }
    if (showTitle) {
      chartBehaviors.add(charts.ChartTitle(title,
          behaviorPosition: charts.BehaviorPosition.bottom,
          titleOutsideJustification:
              charts.OutsideJustification.middleDrawArea));
    }

    // Build the chart widget.
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      primaryMeasureAxis: new charts.NumericAxisSpec(
          tickFormatterSpec: dataFormatter,
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
              zeroBound: true,
              dataIsInWholeNumbers: !per100k,
              desiredMinTickCount: 3,
              desiredMaxTickCount: 7)),
      behaviors: chartBehaviors,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one or more series.
  List<charts.Series<TimeSeriesCovid, DateTime>> createTimeseries(
      CovidEntitiesPageModel pageModel,
      List<List<String>> paths,
      List<int> timestamps,
      List<List<double>> seriesDataList) {
    // Load chart series data.
    var chartDataList = <List<TimeSeriesCovid>>[];
    for (var s = 0; s < seriesDataList.length; ++s) {
      var chartData = <TimeSeriesCovid>[];
      // Use series data length instead of timestamp length as series data may
      // not be populated yet.
      for (var t = 0; t < seriesDataList[s].length; t++) {
        chartData.add(new TimeSeriesCovid(
            DateTime.fromMillisecondsSinceEpoch(1000 * timestamps[t]),
            seriesDataList[s][t]));
      }
      chartDataList.add(chartData);
    }

    // Get colors for chart data series.
    List<Color> seriesColors = pageModel.chartColors(paths, seriesName);

    // Build the data series.
    var chartSeriesList;
    for (var s = 0; s < seriesDataList.length; ++s) {
      final regionName = (paths[s].length > 0) ? '${paths[s].last} ' : '';
      var chartSeries = new charts.Series<TimeSeriesCovid, DateTime>(
        id: '$regionName',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(seriesColors[s]),
        domainFn: (TimeSeriesCovid metric, _) => metric.time,
        measureFn: (TimeSeriesCovid metric, _) => metric.value,
        data: chartDataList[s],
      );
      if (chartSeriesList == null) {
        chartSeriesList = [chartSeries];
      } else {
        chartSeriesList.add(chartSeries);
      }
    }

    return chartSeriesList;
  }
}

/// Covid time series data type.
class TimeSeriesCovid {
  final DateTime time;
  final double value;

  TimeSeriesCovid(this.time, this.value);
}
