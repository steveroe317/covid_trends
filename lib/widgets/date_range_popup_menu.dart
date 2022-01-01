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

class DateRangePopupMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
        icon: const Icon(Icons.date_range),
        tooltip: 'Date Range',
        onSelected: (int seriesLength) {
          var pageModel =
              Provider.of<AppDisplayStateModel>(context, listen: false);
          pageModel.setSeriesLength(seriesLength);
        },
        itemBuilder: (BuildContext context) {
          var pageModel =
              Provider.of<AppDisplayStateModel>(context, listen: false);
          return List<PopupMenuEntry<int>>.from([0, 365, 240, 120, 60].map(
            (days) => CheckedPopupMenuItem(
                child: Text(days == 0
                    ? 'Full History'
                    : (days == 365)
                        ? 'Past Year'
                        : '$days Days'),
                value: days,
                checked: days == pageModel.seriesLength),
          ));
        });
  }
}
