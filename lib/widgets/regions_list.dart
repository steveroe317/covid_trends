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

import 'package:covid_trends/theme/size_scale.dart';
import 'package:covid_trends/widgets/ui_parameters.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';
import '../models/covid_timeseries_model.dart';
import 'regions_list_header.dart';
import 'regions_list_item.dart';
import 'regions_list_search.dart';
//import 'debug_popup_menu.dart';
import 'ui_colors.dart';
import 'ui_parameters.dart';

class RegionsList extends StatelessWidget {
  RegionsList(this._onRegionPressed);

  final void Function(CovidTimeseriesModel, List<String>) _onRegionPressed;
  final ScrollController _childRegionScrollController = ScrollController();

  @override
  build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var pageModel = Provider.of<AppDisplayStateModel>(context);
    var uiParameters = context.watch<UiParameters>();
    final childNames = timeseriesModel.regionChildNames(pageModel.parentPath(),
        sortMetricId: pageModel.sortMetric,
        sortUp: false,
        per100k: pageModel.per100k);
    final currentPath = pageModel.parentPath();
    final numberFormatter = NumberFormat('#,###');

    // Add the region list header.
    List<Widget> stemRegionList = [
      Row(children: [
        Expanded(
            child: Container(
          width: uiParameters.regionRowWidth,
          color: UiColors.regionListHeader,
          child: RegionsListHeader(pageModel, timeseriesModel),
        ))
      ])
    ];

    // Add the parent region to the list.
    for (var index = 0; index < currentPath.length; ++index) {
      final path = currentPath.sublist(0, index + 1);
      var depth =
          (index == 0) ? RegionsListItemDepth.root : RegionsListItemDepth.stem;
      stemRegionList.add(Row(children: [
        Expanded(
            child: Container(
                color: UiColors.regionListStem,
                child: RegionsListItem(path, depth, _onRegionPressed, pageModel,
                    timeseriesModel, numberFormatter)))
      ]));
    }

    if (pageModel.isRegionSearchActive) {
      stemRegionList.add(Row(children: [
        Expanded(
            child: Container(
          width: uiParameters.regionRowWidth,
          color: UiColors.regionListHeader,
          child: RegionsListSearch(pageModel),
        ))
      ]));
    }

    // Add the children of the last parent region.
    List<Widget> childRegionList = [];
    for (var name in childNames) {
      if (name
          .toLowerCase()
          .contains(pageModel.regionSearchString.toLowerCase())) {
        childRegionList.add(RegionsListItem(
            [...currentPath, name],
            RegionsListItemDepth.leaf,
            _onRegionPressed,
            pageModel,
            timeseriesModel,
            numberFormatter));
      }
    }
    stemRegionList.add(Expanded(
        child: Scrollbar(
            isAlwaysShown: true,
            controller: _childRegionScrollController,
            thickness: SizeScale.px8,
            child: ListView(
                controller: _childRegionScrollController,
                children: childRegionList))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stemRegionList,
    );
  }
}
