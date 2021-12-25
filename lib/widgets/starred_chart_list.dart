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
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';
import '../models/model_constants.dart';
import '../theme/size_scale.dart';
import 'star_actions_popup_menu.dart';
import 'ui_colors.dart';
import 'ui_parameters.dart';

class StarredChartList extends StatelessWidget {
  StarredChartList(this._onSavedChartPressed);

  final void Function(AppDisplayStateModel, String) _onSavedChartPressed;
  final ScrollController _starredListController = ScrollController();

  @override
  build(BuildContext context) {
    var uiParameters = context.watch<UiParameters>();
    var pageModel = Provider.of<AppDisplayStateModel>(context);

    List<Widget> starList = [
      Row(children: [
        Expanded(
            child: Container(
                width: uiParameters.entityRowWidth,
                color: UiColors.entityListHeader,
                child: _StarredChartListHeader())),
      ])
    ];

    var starNames = List<String>.from(pageModel
        .getStarredNames()
        .where((element) => element != ModelConstants.startupStarName));
    starNames.sort();

    List<Widget> starredCharts = [];
    for (var starName in starNames) {
      starredCharts.add(_StarredChartListItem(starName, _onSavedChartPressed));
    }
    starList.add(Expanded(
        child: Scrollbar(
            isAlwaysShown: true,
            controller: _starredListController,
            thickness: SizeScale.px8,
            child: ListView(
                controller: _starredListController, children: starredCharts))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: starList,
    );
  }
}

class _StarredChartListHeader extends StatelessWidget {
  @override
  build(BuildContext context) {
    var uiParameters = context.read<UiParameters>();
    return Container(
      width: uiParameters.entityRowWidth,
      padding: EdgeInsets.only(left: 0, right: SizeScale.px12),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          width: uiParameters.entityButtonWidth,
          child: TextButton(
            onPressed: null,
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(UiColors.darkGreyText),
                alignment: AlignmentDirectional(0, 0)),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Saved Charts',
                  style: uiParameters.entityButtonTextStyle,
                )),
          ),
        ),
        Opacity(
            opacity: 0.0,
            child: IconButton(
              icon: Icon(Icons.ac_unit),
              onPressed: null,
            )),
      ]),
    );
  }
}

class _StarredChartListItem extends StatelessWidget {
  _StarredChartListItem(this.savedChartName, this.onSavedChartPressed);

  final String savedChartName;
  final void Function(AppDisplayStateModel, String) onSavedChartPressed;

  @override
  build(BuildContext context) {
    var uiParameters = context.read<UiParameters>();
    var pageModel = Provider.of<AppDisplayStateModel>(context, listen: false);
    return Container(
      width: uiParameters.entityRowWidth,
      color: (savedChartName == pageModel.selectedStarName)
          ? UiColors.entityListSelected
          : null,
      padding: EdgeInsets.only(left: 0, right: SizeScale.px12),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        SizedBox(
          width: uiParameters.starredButtonWidth,
          child: TextButton(
            onPressed: () {
              onSavedChartPressed(pageModel, savedChartName);
            },
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(UiColors.darkGreyText),
                alignment: AlignmentDirectional(0, 0)),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  savedChartName,
                  style: uiParameters.entityButtonTextStyle,
                )),
          ),
        ),
        buildStarActionsPopupMenuButton(context, savedChartName),
      ]),
    );
  }
}
