import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';

class SimpleCovidChart extends StatelessWidget {
  final List<String> path;
  final String seriesName;
  final int seriesLength;
  final bool per100k;
  final Color seriesColor;
  final bool showTitle;
  final bool animate = true;

  SimpleCovidChart(this.path, this.seriesName, this.seriesLength, this.per100k,
      this.seriesColor, this.showTitle);

  @override
  Widget build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);
    var timestamps =
        timeseriesModel.entityTimestamps(path, seriesLength: seriesLength);
    var seriesData = timeseriesModel.entitySeriesData(path, seriesName,
        seriesLength: seriesLength, per100k: per100k);
    var seriesList = createTimeseries(timestamps, seriesData);
    var regionName = (path.length > 0) ? '${path.last} ' : '';
    var scaleSuffix = (pageModel.per100k) ? ' per 100k' : '';
    var title = '$regionName$seriesName$scaleSuffix';

    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      behaviors: (showTitle)
          ? [
              new charts.ChartTitle(title,
                  behaviorPosition: charts.BehaviorPosition.bottom,
                  titleOutsideJustification:
                      charts.OutsideJustification.middleDrawArea),
            ]
          : [],
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one series.
  List<charts.Series<TimeSeriesCovid, DateTime>> createTimeseries(
      List<int> timestamps, List<double> values) {
    List<TimeSeriesCovid> chartData = <TimeSeriesCovid>[];
    for (var i = 0; i < timestamps.length; i++) {
      chartData.add(new TimeSeriesCovid(
          DateTime.fromMillisecondsSinceEpoch(1000 * timestamps[i]),
          values[i]));
    }

    final regionName = (path.length > 0) ? '${path.last} ' : '';
    return [
      new charts.Series<TimeSeriesCovid, DateTime>(
        id: '$regionName',
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(seriesColor),
        domainFn: (TimeSeriesCovid metric, _) => metric.time,
        measureFn: (TimeSeriesCovid metric, _) => metric.value,
        data: chartData,
      )
    ];
  }
}

/// Covid time series data type.
class TimeSeriesCovid {
  final DateTime time;
  final double value;

  TimeSeriesCovid(this.time, this.value);
}
