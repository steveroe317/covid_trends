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

enum SingleChartLineWidth {
  width_0_5,
  width_1_0,
  width_1_5,
  width_2_0,
  width_2_5,
  width_3_0,
  width_3_5,
  width_4_0
}

extension SingleChartLineWidthDoubles on SingleChartLineWidth {
  double toDouble() {
    switch (this) {
      case SingleChartLineWidth.width_0_5:
        return 0.5;
      case SingleChartLineWidth.width_1_0:
        return 1.0;
      case SingleChartLineWidth.width_1_5:
        return 1.5;
      case SingleChartLineWidth.width_2_0:
        return 2.0;
      case SingleChartLineWidth.width_2_5:
        return 2.5;
      case SingleChartLineWidth.width_3_0:
        return 3.0;
      case SingleChartLineWidth.width_3_5:
        return 3.5;
      case SingleChartLineWidth.width_4_0:
        return 4.0;
    }
  }

  static SingleChartLineWidth fromDouble(double value) {
    if (value == 0.5) {
      return SingleChartLineWidth.width_0_5;
    } else if (value == 1.0) {
      return SingleChartLineWidth.width_1_0;
    } else if (value == 1.5) {
      return SingleChartLineWidth.width_1_5;
    } else if (value == 2.0) {
      return SingleChartLineWidth.width_2_0;
    } else if (value == 2.5) {
      return SingleChartLineWidth.width_2_5;
    } else if (value == 3.0) {
      return SingleChartLineWidth.width_3_0;
    } else if (value == 3.5) {
      return SingleChartLineWidth.width_3_5;
    } else if (value == 4.0) {
      return SingleChartLineWidth.width_4_0;
    } else {
      return SingleChartLineWidth.width_2_0;
    }
  }
}

class SettingsPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);
    var singleStrokeWidth = SingleChartLineWidthDoubles.fromDouble(
        pageModel.singleChartStrokeWidth);
    var settingsItems = <Widget>[];
    settingsItems.add(ListTile(
      title: Text('Single chart line width (experiment)'),
    ));
    SingleChartLineWidth.values.forEach((value) {
      settingsItems.add(RadioListTile<SingleChartLineWidth>(
        title: Text(value.toDouble().toString()),
        value: value,
        groupValue: singleStrokeWidth,
        onChanged: (SingleChartLineWidth? value) {
          if (value != null) {
            pageModel.singleChartStrokeWidth = value.toDouble();
          }
        },
      ));
    });
    return Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: Center(
          child: ListView(
              padding: EdgeInsets.all(SizeScale.px4), children: settingsItems),
        ));
  }
}
