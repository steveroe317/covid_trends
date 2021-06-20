import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_timeseries_model.dart';

class MultipleCovidChart extends StatelessWidget {
  final List<List<String>> paths;
  final String seriesName;
  final int seriesLength;
  final bool per100k;
  final List<Color> seriesColors;
  final bool animate = true;

  MultipleCovidChart(this.paths, this.seriesName, this.seriesLength,
      this.per100k, this.seriesColors);

  @override
  Widget build(BuildContext context) {
    assert(paths.length == seriesColors.length);

    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var timestamps =
        timeseriesModel.entityTimestamps(paths[0], seriesLength: seriesLength);
    var seriesDataList = paths
        .map((path) => timeseriesModel.entitySeriesData(path, seriesName,
            seriesLength: seriesLength, per100k: per100k))
        .toList();
    var seriesList = createTimeseries(timestamps, seriesDataList);

    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      behaviors: [
        new charts.SeriesLegend(
            desiredMaxColumns: 2, cellPadding: const EdgeInsets.all(2.0))
      ],
    );
  }

  /// Create multiple series.
  List<charts.Series<TimeSeriesCovid, DateTime>> createTimeseries(
      List<int> timestamps, List<List<double>> seriesDataList) {
    var chartDataList = <List<TimeSeriesCovid>>[];
    for (var s = 0; s < seriesDataList.length; ++s) {
      var chartData = <TimeSeriesCovid>[];
      // Use series data length instesad of timestamp length as series data may
      // not be populated yet.
      for (var t = 0; t < seriesDataList[s].length; t++) {
        chartData.add(new TimeSeriesCovid(
            DateTime.fromMillisecondsSinceEpoch(1000 * timestamps[t]),
            seriesDataList[s][t]));
      }
      chartDataList.add(chartData);
    }

    //var chartSeriesList = <charts.Series<TimeSeriesCovid, DateTime>>[];
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
