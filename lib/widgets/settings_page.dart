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
import '../models/starred_chart_examples.dart';
import '../theme/size_scale.dart';

class SettingsPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);

    var settingsItems = <Widget>[];
    settingsItems.add(ListTile(
      leading: Icon(Icons.refresh),
      title: Text('Reload Saved Example Charts',
          style: TextStyle(fontSize: SizeScale.px16)),
      onTap: () {
        pageModel.addStarredList(starredChartExamples);
      },
    ));

    return Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: Center(
          child: ListView(
              padding: EdgeInsets.all(SizeScale.px4), children: settingsItems),
        ));
  }
}
