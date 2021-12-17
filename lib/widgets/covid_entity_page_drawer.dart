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

import 'package:covid_trends/models/app_display_state_model.dart';
import 'package:covid_trends/theme/size_scale.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/palette_colors.dart';
import 'covid_about_list_tile.dart';
import 'experiments_page.dart';
import 'settings_page.dart';
import 'ui_parameters.dart';

class CovidEntityPageDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var uiParameters = context.read<UiParameters>();
    var pageModel = context.watch<AppDisplayStateModel>();
    return SafeArea(
        left: true,
        right: true,
        top: true,
        bottom: true,
        minimum: EdgeInsets.zero,
        child: Container(
            width: 250,
            color: PaletteColors.coolGrey.shade100,
            child: ListView(padding: EdgeInsets.zero, children: [
              Container(
                  height: uiParameters.drawerHeaderHeight,
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      color: PaletteColors.lightBlueVivid.shade700,
                    ),
                    child: Text('Covid Flows',
                        style: TextStyle(
                            color: PaletteColors.coolGrey.shade50,
                            fontSize: SizeScale.px24,
                            fontWeight: FontWeight.w500)),
                  )),
              ListTile(
                  leading: Icon(Icons.star),
                  title: Text('Saved Charts'),
                  onTap: () {
                    pageModel.selectedStarName = '';
                    // Explictly popping and pushing here because using
                    // Navigator.pushNamedAndRemoveUntil here does not add
                    // a back arrow to the scaffold.
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/starred_charts');
                  }),
              ListTile(
                  leading: Icon(Icons.tune),
                  title: Text('Adjust Chart Options'),
                  onTap: () {
                    pageModel.selectedStarName = '';
                    // Explictly popping and pushing here because using
                    // Navigator.pushNamedAndRemoveUntil here does not add
                    // a back arrow to the scaffold.
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/adjust_charts');
                  }),
              ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Container(child: SettingsPage())));
                  }),
              ListTile(
                  leading: Icon(Icons.science),
                  title: Text('Experiments'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Container(child: ExperimentsPage())));
                  }),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Help'),
                onTap: () {
                  Navigator.pop(context);
                  _launchURL('https://www.roedesigns.com/covid-flows');
                },
              ),
              CovidAboutListTile(),
            ])));
  }

  void _launchURL(String urlString) async {
    if (await canLaunch(urlString)) {
      await launch(urlString);
    }
  }
}
