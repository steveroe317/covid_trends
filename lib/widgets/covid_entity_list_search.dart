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
import '../theme/size_scale.dart';
import 'ui_colors.dart';
import 'ui_parameters.dart';

class CovidEntityListSearch extends StatelessWidget {
  final CovidEntitiesPageModel _pageModel;

  CovidEntityListSearch(this._pageModel);

  @override
  build(BuildContext context) {
    var uiParameters = context.read<UiParameters>();
    return Container(
        color: UiColors.entityListStem,
        width: uiParameters.entityRowWidth,
        padding: EdgeInsets.fromLTRB(
            0, SizeScale.px8, SizeScale.px12, SizeScale.px12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _pageModel.entitySearchActive = false;
                _pageModel.entitySearchString = '';
              },
            ),
            SizedBox(
              width: uiParameters.entityButtonWidth,
              child: TextField(
                  autofocus: true,
                  onChanged: (value) {
                    _pageModel.entitySearchString = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: _pageModel.entitySearchString,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(SizeScale.px4),
                  )),
            ),
            Container(
              width: uiParameters.entityMetricWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '',
                  style: uiParameters.entityMetricTextStyle,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ));
  }
}
