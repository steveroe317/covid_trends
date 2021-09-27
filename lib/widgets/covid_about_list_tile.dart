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

import 'package:covid_trends/theme/size_scale.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CovidAboutListTile extends AboutListTile {
  // TODO: use package_info_plus to get app name and version info.
  @override
  Widget build(BuildContext context) {
    return AboutListTile(
      icon: Icon(Icons.info),
      child: Text('About'),
      applicationName: 'Covid Flows',
      applicationVersion: '1.0.7',
      applicationLegalese: '© 2021 Roe Designs',
      aboutBoxChildren: [
        Text(
          '\nCovid Flows shows COVID-19 trend graphs for countries and US '
          'states and counties.',
          style: TextStyle(color: Colors.black),
        ),
        RichText(
            text: TextSpan(
                style: TextStyle(fontSize: SizeScale.px16),
                children: <TextSpan>[
              TextSpan(text: '\n'),
              TextSpan(
                text: 'Data is from the COVID-19 Data Repository '
                    'by the Center for Systems Science and Engineering (CSSE) '
                    'at Johns Hopkins University at ',
                style: TextStyle(color: Colors.black),
              ),
              TextSpan(
                  text: 'https://github.com/CSSEGISandData/COVID-19',
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchURL('https://github.com/CSSEGISandData/COVID-19');
                    }),
            ]))
      ],
    );
  }

  void _launchURL(String urlString) async {
    if (await canLaunch(urlString)) {
      await launch(urlString);
    }
  }
}
