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

class InitializationErrorPage extends StatelessWidget {
  final String message;
  final void Function() retry;

  InitializationErrorPage(this.retry, this.message);

  @override
  build(BuildContext context) {
    return MaterialApp(
        color: Colors.grey,
        home: Scaffold(
            body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Sorry, there was an error $message',
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                textScaleFactor: 2.0,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: retry,
              child: Text('Please try again',
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  textScaleFactor: 2.0,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ]),
        )));
  }
}
