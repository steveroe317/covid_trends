import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_timeseries_model.dart';

class SimpleCovidChart extends StatelessWidget {
  final String seriesName;
  final bool animate = true;

  SimpleCovidChart(this.seriesName);

  @override
  Widget build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var timestamps = timeseriesModel.timestamps;
    var confirmed7Days = timeseriesModel.seriesData(this.seriesName);
    var seriesList = createTimeseries(timestamps, confirmed7Days);

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
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesCovid sales, _) => sales.time,
        measureFn: (TimeSeriesCovid sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeriesCovid {
  final DateTime time;
  final int sales;

  TimeSeriesCovid(this.time, this.sales);
}
