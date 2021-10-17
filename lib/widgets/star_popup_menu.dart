// Copyright 2021 Stephen Roe
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.import 'dart:collection';

//import 'package:flutter/material/dialog.dart';
import 'package:covid_trends/widgets/ui_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
import '../models/model_constants.dart';
import 'covid_chart_group_page.dart';
import 'highlight_colors_dialog.dart';
import 'ui_constants.dart';

PopupMenuButton<String> buildStarPopupMenuButton(BuildContext context,
    {bool openChartPage = false}) {
  return PopupMenuButton<String>(
      icon: const Icon(Icons.star),
      tooltip: 'Starred Charts',
      onSelected: (String starName) {
        var pageModel =
            Provider.of<CovidEntitiesPageModel>(context, listen: false);
        var timeseriesModel =
            Provider.of<CovidTimeseriesModel>(context, listen: false);
        if (starName == UiConstants.saveStar) {
          showDialog(context: context, builder: buildSaveStarDialog);
        } else {
          pageModel.loadStar(starName);
          List<List<String>> starPaths = pageModel.getAllModelPaths();
          timeseriesModel.loadEntities(starPaths);
          if (openChartPage) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Container(child: CovidChartGroupPage())),
            );
          }
        }
      },
      itemBuilder: (BuildContext context) {
        var pageModel =
            Provider.of<CovidEntitiesPageModel>(context, listen: false);
        var starNames = List<String>.from(pageModel
            .getStarredNames()
            .where((element) => element != ModelConstants.startupStarName));
        starNames.sort();
        var menuEntries = List<PopupMenuEntry<String>>.from(
            starNames.map((name) => PopupMenuItem(
                value: name,
                child: ListTile(
                  title: Text(name),
                  trailing: buildStarActionsPopupMenuButton(context, name),
                ))));
        if (menuEntries.length > 0) {
          menuEntries.insert(0, PopupMenuDivider());
        }
        TextStyle? saveStyle =
            (openChartPage) ? TextStyle(color: UiColors.disabledText) : null;
        menuEntries.insert(
            0,
            PopupMenuItem(
                value: UiConstants.saveStar,
                enabled: !openChartPage,
                child: ListTile(
                  title: Text(
                    UiConstants.saveStar,
                    style: saveStyle,
                  ),
                  trailing: Opacity(opacity: 0.0, child: Icon(Icons.edit)),
                )));
        return menuEntries;
      });
}

PopupMenuButton<String> buildStarActionsPopupMenuButton(
    BuildContext context, String name) {
  var pageModel = Provider.of<CovidEntitiesPageModel>(context, listen: false);

  return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String action) {
        pageModel.editStarName = name;
        if (action == 'Rename') {
          showDialog(context: context, builder: buildRenameStarDialog);
        } else if (action == 'Replace') {
          showDialog(context: context, builder: buildReplaceStarDialog);
        } else if (action == 'Delete') {
          showDialog(context: context, builder: buildDeleteStarDialog);
        }
      },
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          PopupMenuItem(value: 'Rename', child: Text('Rename')),
          PopupMenuItem(value: 'Replace', child: Text('Replace')),
          PopupMenuItem(value: 'Delete', child: Text('Delete')),
        ];
      });
}

Widget buildSaveStarDialog(BuildContext context) {
  var pageModel = Provider.of<CovidEntitiesPageModel>(context, listen: false);
  var saveName = 'Starred Chart';
  return Dialog(
      child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Padding(
          padding:
              EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
          child: Text('Save Starred Chart')),
      Container(
          constraints: BoxConstraints(minWidth: 200.0, maxWidth: 300.0),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: TextField(
              autofocus: true,
              onChanged: (value) {
                saveName = value;
              },
              controller: TextEditingController(),
              decoration: InputDecoration(
                labelText: 'Enter name here',
                hintText: saveName,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(20.0),
              ))),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              pageModel.addStar(saveName);
            },
            child: Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      )
    ],
  ));
}

Widget buildRenameStarDialog(BuildContext context) {
  var pageModel = Provider.of<CovidEntitiesPageModel>(context, listen: false);
  var oldName = pageModel.editStarName;
  var newName = oldName;
  return Dialog(
      child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Padding(
          padding:
              EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
          child: Text('Rename chart "$oldName"?')),
      Container(
          constraints: BoxConstraints(minWidth: 200.0, maxWidth: 300.0),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: TextField(
              autofocus: true,
              onChanged: (value) {
                newName = value;
              },
              controller: TextEditingController(),
              decoration: InputDecoration(
                labelText: 'New name',
                hintText: newName,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(20.0),
              ))),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              if (newName != oldName) {
                pageModel.renameStar(oldName, newName);
              }
              // Pop twice to exit both the dialog and the popup menu.
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Rename'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      )
    ],
  ));
}

Widget buildReplaceStarDialog(BuildContext context) {
  var pageModel = Provider.of<CovidEntitiesPageModel>(context, listen: false);
  var chartName = pageModel.editStarName;
  return Dialog(
      child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Padding(
          padding:
              EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
          child: Text('Replace chart "$chartName" with current chart?')),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              pageModel.deleteStar(chartName);
              pageModel.addStar(chartName);
              // Pop twice to exit both the dialog and the popup menu.
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Replace'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      )
    ],
  ));
}

Widget buildDeleteStarDialog(BuildContext context) {
  var pageModel = Provider.of<CovidEntitiesPageModel>(context, listen: false);
  var chartName = pageModel.editStarName;
  return Dialog(
      child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Padding(
          padding:
              EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
          child: Text('Delete chart "$chartName"?')),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              pageModel.deleteStar(chartName);
              // Pop twice to exit both the dialog and the popup menu.
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      )
    ],
  ));
}
