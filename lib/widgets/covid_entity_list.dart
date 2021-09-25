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

import 'package:covid_trends/widgets/ui_parameters.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
import 'covid_entity_list_header.dart';
import 'covid_entity_list_item.dart';
//import 'debug_popup_menu.dart';
import 'ui_colors.dart';
import 'ui_parameters.dart';

class CovidEntityList extends StatelessWidget {
  final void Function(CovidTimeseriesModel, List<String>) _onRegionPressed;

  CovidEntityList(this._onRegionPressed);

  @override
  build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);
    var uiParameters = context.watch<UiParameters>();
    final childNames = timeseriesModel.entityChildNames(
        pageModel.entityPagePath(),
        sortBy: pageModel.sortMetric,
        sortUp: false,
        per100k: pageModel.per100k);
    final currentPath = pageModel.entityPagePath();
    final numberFormatter = NumberFormat('#,###');

    // Build base of the entity list with the parent entities.
    List<Widget> stemEntityList = [
      Row(children: [
        Expanded(
            child: Container(
          width: uiParameters.entityRowWidth,
          color: UiColors.entityListHeader,
          child: CovidEntityListHeader(pageModel, timeseriesModel),
        ))
      ])
    ];
    for (var index = 0; index < currentPath.length; ++index) {
      final path = currentPath.sublist(0, index + 1);
      var depth = (index == 0)
          ? CovidEntityListItemDepth.root
          : CovidEntityListItemDepth.stem;
      stemEntityList.add(Row(children: [
        Expanded(
            child: Container(
                color: UiColors.entityListStem,
                child: CovidEntityListItem(path, depth, _onRegionPressed,
                    pageModel, timeseriesModel, numberFormatter)))
      ]));
    }

    // Add the children of the last parent entity.
    List<Widget> childEntityList = [];
    childEntityList.addAll(List<Widget>.from(childNames.map((name) =>
        CovidEntityListItem(
            [...currentPath, name],
            CovidEntityListItemDepth.leaf,
            _onRegionPressed,
            pageModel,
            timeseriesModel,
            numberFormatter))));
    stemEntityList.add(Expanded(child: ListView(children: childEntityList)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stemEntityList,
    );
  }
}