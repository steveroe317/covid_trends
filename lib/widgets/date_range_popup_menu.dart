import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';

PopupMenuButton<int> buildDateRangePopupMenuButton(BuildContext context) {
  return PopupMenuButton<int>(
      icon: const Icon(Icons.date_range),
      tooltip: 'Date Range',
      onSelected: (int seriesLength) {
        var pageModel =
            Provider.of<CovidEntitiesPageModel>(context, listen: false);
        pageModel.setSeriesLength(seriesLength);
      },
      itemBuilder: (BuildContext context) {
        var pageModel =
            Provider.of<CovidEntitiesPageModel>(context, listen: false);
        return List<PopupMenuEntry<int>>.from([0, 240, 120, 60].map(
          (days) => CheckedPopupMenuItem(
              child: Text(days == 0 ? 'Full History' : '$days Days'),
              value: days,
              checked: days == pageModel.seriesLength),
        ));
      });
}
