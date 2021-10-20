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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';

PopupMenuButton<String> buildStarActionsPopupMenuButton(
    BuildContext context, String name) {
  var pageModel = Provider.of<AppDisplayStateModel>(context, listen: false);
  var dialogBuilder = StarActionDialogBuilder();

  return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (String action) {
        pageModel.selectedStarName = name;
        if (action == 'Rename') {
          showDialog(
              context: context, builder: dialogBuilder.buildRenameStarDialog);
        } else if (action == 'Replace') {
          showDialog(
              context: context, builder: dialogBuilder.buildReplaceStarDialog);
        } else if (action == 'Delete') {
          showDialog(
              context: context, builder: dialogBuilder.buildDeleteStarDialog);
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

class StarActionDialogBuilder {
  Widget buildRenameStarDialog(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context, listen: false);
    var oldName = pageModel.selectedStarName;
    var newName = oldName;
    return Dialog(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(
                top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
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
    var pageModel = Provider.of<AppDisplayStateModel>(context, listen: false);
    var chartName = pageModel.selectedStarName;
    return Dialog(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(
                top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
            child: Text('Replace chart "$chartName" with current chart?')),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                pageModel.deleteStar(chartName);
                pageModel.addStar(chartName);
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
    var pageModel = Provider.of<AppDisplayStateModel>(context, listen: false);
    var chartName = pageModel.selectedStarName;
    return Dialog(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: EdgeInsets.only(
                top: 20.0, left: 20.0, right: 20.0, bottom: 10.0),
            child: Text('Delete chart "$chartName"?')),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                pageModel.deleteStar(chartName);
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
}
