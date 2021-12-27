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

class NavigationTarget {
  NavigationTarget(this.iconData, this.label);
  final IconData iconData;
  final String label;
}

class HomePageNavigationTabs {
  static final targets = <NavigationTarget>[
    NavigationTarget(Icons.language, 'Regions'),
    NavigationTarget(Icons.star, 'Starred'),
    NavigationTarget(Icons.tune, 'Adjust'),
  ];
}

class HomePageNavigationBar extends StatelessWidget {
  @override
  build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);
    return BottomNavigationBar(
      items: HomePageNavigationTabs.targets
          .map((target) => BottomNavigationBarItem(
              icon: Icon(target.iconData), label: target.label))
          .toList(),
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
      currentIndex: pageModel.selectedTab,
      onTap: (int index) {
        pageModel.goToTab(index);
      },
    );
  }
}

class HomePageNavigationRail extends StatelessWidget {
  @override
  build(BuildContext context) {
    var pageModel = Provider.of<AppDisplayStateModel>(context);
    return NavigationRail(
      destinations: HomePageNavigationTabs.targets
          .map((target) => NavigationRailDestination(
              icon: Icon(target.iconData), label: Text(target.label)))
          .toList(),
      selectedIndex: pageModel.selectedTab,
      onDestinationSelected: (int index) {
        pageModel.goToTab(index);
      },
    );
  }
}
