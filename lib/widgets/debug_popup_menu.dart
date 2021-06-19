import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_timeseries_model.dart';

PopupMenuButton<String> buildDebugPopupMenuButton(BuildContext context) {
  var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
  return PopupMenuButton<String>(
      icon: const Icon(Icons.plumbing),
      tooltip: 'Internal testing',
      onSelected: (String debugAction) {
        if (debugAction == 'Halve History') {
          timeseriesModel.halveHistory();
        } else if (debugAction == 'Refresh') {
          timeseriesModel.markStale();
        }
      },
      itemBuilder: (BuildContext context) {
        var debugActions = List<String>.from(['Halve History', 'Refresh']);
        return List<PopupMenuEntry<String>>.from(debugActions
            .map((name) => PopupMenuItem(value: name, child: Text(name))));
      });
}
