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

PopupMenuButton<String> buildper100kPopupMenuButton(BuildContext context) {
  final chartTotalsLabel = 'Show Totals';
  final chartPer100kLabel = 'Per 100,000';
  var pageModel = Provider.of<AppDisplayStateModel>(context, listen: false);

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
