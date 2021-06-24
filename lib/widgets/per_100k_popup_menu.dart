import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';

PopupMenuButton<String> buildper100kPopupMenuButton(BuildContext context) {
  final chartTotalsLabel = 'Show Totals';
  final chartPer100kLabel = 'Per 100,000';
  var pageModel = Provider.of<CovidEntitiesPageModel>(context, listen: false);

  return PopupMenuButton<String>(
      icon: const Icon(Icons.group),
      tooltip: 'per 100,000',
      onSelected: (String debugAction) {
        if (debugAction == chartTotalsLabel) {
          pageModel.setPer100k(false);
        } else if (debugAction == chartPer100kLabel) {
          pageModel.setPer100k(true);
        }
      },
      itemBuilder: (BuildContext context) {
        var debugActions =
            List<String>.from([chartTotalsLabel, chartPer100kLabel]);
        return List<PopupMenuEntry<String>>.from(debugActions.map((name) =>
            CheckedPopupMenuItem(
                value: name,
                child: Text(name),
                checked: pageModel.per100k ^ (name == chartTotalsLabel))));
      });
}
