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
import 'highlight_colors_dialog.dart';
import 'highlight_region_dialog.dart';

PopupMenuButton<String> buildCompareRegionPopupMenuButton(
    BuildContext context) {
  final singleRegionLabel = 'Show One Region';
  final multipleRegionLabel = 'Compare Regions';
  final highlightRegionsLabel = 'Highlight Regions';
  final highlightAdvancedLabel = 'Highlight Options';
  var pageModel = Provider.of<CovidEntitiesPageModel>(context);
  var compareActions = <String>[singleRegionLabel, multipleRegionLabel];

  var menuItems = List<PopupMenuEntry<String>>.from(compareActions.map((name) =>
      CheckedPopupMenuItem(
          value: name,
          child: Text(name),
          checked: pageModel.compareRegion ^ (name == singleRegionLabel))));

  if (pageModel.compareRegion && pageModel.comparisonPathList.length > 1) {
    menuItems.add(PopupMenuDivider());
    menuItems.add(CheckedPopupMenuItem(
        value: highlightRegionsLabel,
        child: Text(highlightRegionsLabel),
        checked: false));
    menuItems.add(CheckedPopupMenuItem(
        value: highlightAdvancedLabel,
        child: Text(highlightAdvancedLabel),
        checked: false));
  }

  return PopupMenuButton<String>(
      icon: const Icon(Icons.stacked_line_chart),
      tooltip: 'Single or Comparison Region Charts',
      onSelected: (String menuAction) {
        if (menuAction == singleRegionLabel) {
          pageModel.setCompareRegion(false);
        } else if (menuAction == multipleRegionLabel) {
          pageModel.setCompareRegion(true);
        } else if (menuAction == highlightRegionsLabel) {
          showDialog(context: context, builder: buildHighlightRegionDialog);
        } else if (menuAction == highlightAdvancedLabel) {
          showDialog(context: context, builder: buildHighlightColorsDialog);
        }
      },
      itemBuilder: (BuildContext context) {
        return menuItems;
      });
}
