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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/app_display_state_model.dart';
import '../models/model_constants.dart';
import '../models/starred_chart_examples.dart';
import '../models/covid_timeseries_model.dart';
import '../theme/size_scale.dart';

class SettingsPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context, listen: false);
    var timeseriesModel =
        Provider.of<CovidTimeseriesModel>(context, listen: false);

    var settingsItems = <Widget>[];
    settingsItems.add(ListTile(
      leading: Icon(Icons.info),
      title: Text('${_lastRootDataMessage(timeseriesModel)}'),
    ));
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

  String _lastRootDataMessage(CovidTimeseriesModel timeseriesModel) {
    var timestamps =
        timeseriesModel.entityTimestamps([ModelConstants.rootEntityName]);
    if (timestamps.isEmpty) {
      return 'No Covid data loaded';
    }
    var date = DateTime.fromMillisecondsSinceEpoch(1000 * timestamps.last);
    return 'Covid data though ${DateFormat('yyyy-MM-dd').format(date)}';
  }
}
