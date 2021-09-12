import 'package:covid_trends/theme/size_scale.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                applicationVersion: '1.0.2',
                applicationLegalese: '© 2021 Roe Designs',
                aboutBoxChildren: [
                  Text('Covid Flows shows COVID-19 case and death graphs '
                      'for countries and selected US states and counties '
                      'using Johns Hopkins data.'),
                ],
              ),
              ListTile(
                leading: Icon(Icons.help),
                title: Text('Help'),
                onTap: () {
                  _launchURL('https://www.roedesigns.com/covid-flows');
                },
              )
            ])));
  }

  void _launchURL(String urlString) async {
    if (await canLaunch(urlString)) {
      await launch(urlString);
    }
  }
}
