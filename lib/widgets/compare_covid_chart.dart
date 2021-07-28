import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';

class CompareCovidChart extends StatelessWidget {
  final List<List<String>> paths;
  final String seriesName;
  final int seriesLength;
  final bool per100k;
  final List<Color> seriesColors;
  final bool showTitle;
  final bool animate = true;

  CompareCovidChart(this.paths, this.seriesName, this.seriesLength,
      this.per100k, this.seriesColors, this.showTitle);

  @override
  Widget build(BuildContext context) {
    assert(paths.length == seriesColors.length);

    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);

    var scaleSuffix = (pageModel.per100k) ? ' per 100k' : '';
    var title = '$seriesName$scaleSuffix';

    var seriesDataList = paths
        .map((path) => timeseriesModel.entitySeriesData(path, seriesName,
            seriesLength: seriesLength, per100k: per100k))
        .toList();
    // Get timestamps from the root of the admin entity tree, as it is most
    // likely to have been loaded already.
    var timestamps = timeseriesModel.entityTimestamps(paths[0].sublist(0, 1),
        seriesLength: seriesLength);

    // If the model timeseries data is not yet loaded, subsitute stub values.
    // When the data is loaded a rebuild will be triggered.
    if (timestamps.isEmpty) {
      timestamps = [0, 1];
    }
    for (int index = 0; index < seriesDataList.length; ++index) {
      if (seriesDataList[index].isEmpty) {
        seriesDataList[index] = List<double>.filled(timestamps.length, 0.0);
      }
    }

    var seriesList = createTimeseries(timestamps, seriesDataList);

    List<charts.ChartBehavior> chartBehaviors = [
      new charts.SeriesLegend(
          desiredMaxColumns: 2, cellPadding: const EdgeInsets.all(2.0))
    ];
    if (showTitle) {
      chartBehaviors.add(new charts.ChartTitle(title,
          behaviorPosition: charts.BehaviorPosition.bottom,
          titleOutsideJustification:
              charts.OutsideJustification.middleDrawArea));
    }

    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      behaviors: chartBehaviors,
    );
  }

  /// Create multiple series.
  List<charts.Series<TimeSeriesCovid, DateTime>> createTimeseries(
      List<int> timestamps, List<List<double>> seriesDataList) {
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
