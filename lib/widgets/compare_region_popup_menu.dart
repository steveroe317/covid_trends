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
