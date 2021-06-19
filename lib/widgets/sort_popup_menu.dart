import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';

PopupMenuButton<String> buildSortPopupMenuButton(BuildContext context) {
  return PopupMenuButton<String>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort By',
      onSelected: (String sortMetric) {
        var pageModel =
            Provider.of<CovidEntitiesPageModel>(context, listen: false);
        pageModel.sortMetric = sortMetric;
      },
      itemBuilder: (BuildContext context) {
        var timeseriesModel =
            Provider.of<CovidTimeseriesModel>(context, listen: false);
        var pageModel =
            Provider.of<CovidEntitiesPageModel>(context, listen: false);
        var metricNames = timeseriesModel.sortMetrics();
        metricNames.sort();
        metricNames.insert(0, timeseriesModel.noSortMetricName);
        return List<PopupMenuEntry<String>>.from(metricNames.map((name) =>
            CheckedPopupMenuItem(
                value: name,
                child: Text(name),
                checked: name == pageModel.sortMetric)));
      });
}
