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

class StarPopupDialogButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.star),
      tooltip: 'Save Chart',
      onPressed: () {
        showDialog(context: context, builder: buildSaveStarDialog);
      },
    );
  }
}

Widget buildSaveStarDialog(BuildContext context) {
  var pageModel = Provider.of<AppDisplayStateModel>(context, listen: false);
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
