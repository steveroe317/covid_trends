import 'package:covid_trends/theme/size_scale.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/palette_colors.dart';
import 'ui_parameters.dart';

class CovidTrendsNavigationSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var uiParameters = context.read<UiParameters>();
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
                    child: Text('Covid Trends',
                        style: TextStyle(
                            color: PaletteColors.coolGrey.shade50,
                            fontSize: SizeScale.px24,
                            fontWeight: FontWeight.w500)),
                  )),
              // TODO: use package_info_plus to get app name and version info.
              AboutListTile(
                icon: Icon(Icons.info),
                child: Text('About'),
                applicationName: 'Covid Flows',
                applicationVersion: '0.1.1',
                applicationLegalese: '© 2021 Roe Designs',
                aboutBoxChildren: [
                  Text('The Covid Trends app shows confirmed case and death '
                      'charts for countries and selected US states and counties '
                      'based on data from Johns Hopkins.'),
                  Text('It is built using Google Flutter and uses '
                      'Google Firebase as a back end data store.'),
                ],
              ),
            ])));
  }
}
