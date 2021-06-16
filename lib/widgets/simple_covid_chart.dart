import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_timeseries_model.dart';

class SimpleCovidChart extends StatelessWidget {
  final List<String> path;
  final String seriesName;
  final int seriesLength;
  final bool per100k;
  final Color seriesColor;
  final bool animate = true;

  SimpleCovidChart(this.path, this.seriesName, this.seriesLength, this.per100k,
      this.seriesColor);

  @override
  Widget build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var timestamps =
        timeseriesModel.entityTimestamps(path, seriesLength: seriesLength);
    var seriesData = timeseriesModel.entitySeriesData(path, seriesName,
        seriesLength: seriesLength, per100k: per100k);
    var seriesList = createTimeseries(timestamps, seriesData);

    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one series.
  List<charts.Series<TimeSeriesCovid, DateTime>> createTimeseries(
      List<int> timestamps, List<int> values) {
    List<TimeSeriesCovid> data = <TimeSeriesCovid>[];
    for (var i = 0; i < timestamps.length; i++) {
      data.add(new TimeSeriesCovid(
          DateTime.fromMillisecondsSinceEpoch(1000 * timestamps[i]),
          values[i]));
    }

    return [
      new charts.Series<TimeSeriesCovid, DateTime>(
        id: 'Metric',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(seriesColor),
        domainFn: (TimeSeriesCovid metric, _) => metric.time,
        measureFn: (TimeSeriesCovid metric, _) => metric.value,
        data: data,
      )
    ];
  }
}

/// Covid time series data type.
class TimeSeriesCovid {
  final DateTime time;
  final int value;

  TimeSeriesCovid(this.time, this.value);
}
