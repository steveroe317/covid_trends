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
import 'ui_colors.dart';
import 'ui_parameters.dart';

class RegionsListSearch extends StatelessWidget {
  final AppDisplayStateModel _pageModel;

  RegionsListSearch(this._pageModel);

  @override
  build(BuildContext context) {
    var uiParameters = context.read<UiParameters>();
    return Container(
        color: UiColors.regionListStem,
        width: uiParameters.regionRowWidth,
        padding: EdgeInsets.fromLTRB(
            0, SizeScale.px8, SizeScale.px12, SizeScale.px12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _pageModel.isRegionSearchActive = false;
                _pageModel.regionSearchString = '';
              },
            ),
            SizedBox(
              width: uiParameters.regionButtonWidth,
              child: TextField(
                  autofocus: true,
                  onChanged: (value) {
                    _pageModel.regionSearchString = value.trim();
                  },
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: _pageModel.regionSearchString,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(SizeScale.px4),
                  )),
            ),
            Container(
              width: uiParameters.regionMetricWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '',
                  style: uiParameters.regionMetricTextStyle,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ));
  }
}
