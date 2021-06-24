import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';

PopupMenuButton<String> buildCompareRegionPopupMenuButton(
    BuildContext context) {
  final singleRegionLabel = 'Show One Region';
  final multipleRegionLabel = 'Compare Regions';
  var pageModel = Provider.of<CovidEntitiesPageModel>(context, listen: false);

  return PopupMenuButton<String>(
      icon: const Icon(Icons.stacked_line_chart),
      tooltip: 'Single or Comparison Region Charts',
      onSelected: (String debugAction) {
        if (debugAction == singleRegionLabel) {
          pageModel.setCompareRegion(false);
        } else if (debugAction == multipleRegionLabel) {
          pageModel.setCompareRegion(true);
        }
      },
      itemBuilder: (BuildContext context) {
        var debugActions =
            List<String>.from([singleRegionLabel, multipleRegionLabel]);
        return List<PopupMenuEntry<String>>.from(debugActions.map((name) =>
            CheckedPopupMenuItem(
                value: name,
                child: Text(name),
                checked:
                    pageModel.compareRegion ^ (name == singleRegionLabel))));
      });
}
