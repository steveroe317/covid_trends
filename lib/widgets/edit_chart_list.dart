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
import '../theme/size_scale.dart';
import 'highlight_colors_dialog.dart';
import 'highlight_region_dialog.dart';

class EditChartList extends StatelessWidget {
  final ScrollController _optionsListController = ScrollController();

  @override
  build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);

    var regionHighlighted = <String, bool>{};
    for (var path in pageModel.comparisonPathList) {
      var pathName = RegionPath.name(path);
      regionHighlighted[pathName] = pageModel.isComparisonPathHighlighted(path);
    }

    var listDensity = VisualDensity(
        horizontal: VisualDensity.minimumDensity,
        vertical: VisualDensity.minimumDensity);

    var optionsWidgets = <Widget>[];
    optionsWidgets.addAll(editHighlightRegionsWidgets(
        pageModel, true, regionHighlighted, listDensity));
    optionsWidgets.addAll(editHighlightsWidgets(pageModel));

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Scrollbar(
              isAlwaysShown: true,
              controller: _optionsListController,
              thickness: SizeScale.px8,
              child: Container(
                  child: ListView(
                      controller: _optionsListController,
                      children: optionsWidgets))));
    });
  }
}
