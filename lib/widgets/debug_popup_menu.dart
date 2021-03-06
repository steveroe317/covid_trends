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

import '../models/covid_timeseries_model.dart';

PopupMenuButton<String> buildDebugPopupMenuButton(BuildContext context) {
  var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
  return PopupMenuButton<String>(
      icon: const Icon(Icons.plumbing),
      tooltip: 'Internal testing',
      onSelected: (String debugAction) {
        if (debugAction == 'Halve History') {
          timeseriesModel.halveHistory();
        } else if (debugAction == 'Refresh') {
          timeseriesModel.markStale();
        }
      },
      itemBuilder: (BuildContext context) {
        var debugActions = List<String>.from(['Halve History', 'Refresh']);
        return List<PopupMenuEntry<String>>.from(debugActions
            .map((name) => PopupMenuItem(value: name, child: Text(name))));
      });
}
