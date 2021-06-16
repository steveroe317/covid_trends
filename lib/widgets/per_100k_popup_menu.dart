import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';

PopupMenuButton<String> buildper100kPopupMenuButton(BuildContext context) {
  var pageModel = Provider.of<CovidEntitiesPageModel>(context, listen: false);

  return PopupMenuButton<String>(
      icon: const Icon(Icons.group),
      tooltip: 'Internal testing',
      onSelected: (String debugAction) {
        if (debugAction == 'Total') {
          pageModel.setPer100k(false);
        } else if (debugAction == 'Per 100,000') {
          pageModel.setPer100k(true);
        }
      },
      itemBuilder: (BuildContext context) {
        var debugActions = List<String>.from(['Total', 'Per 100,000']);
        return List<PopupMenuEntry<String>>.from(debugActions.map((name) =>
            CheckedPopupMenuItem(
                value: name,
                child: Text(name),
                checked: pageModel.per100k ^ (name == 'Total'))));
      });
}
