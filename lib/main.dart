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

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid_trends/models/model_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/covid_timeseries_model.dart';
import 'models/covid_entities_page_model.dart';
import 'theme/palette_colors.dart';
import 'widgets/covid_entities_page.dart';
import 'widgets/initialization_error_page.dart';
import 'widgets/loading_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => CovidTimeseriesModel()),
      ChangeNotifierProvider(
          create: (context) => CovidEntitiesPageModel(['World'])),
    ], child: _CovidAppFirebaseWrapper()),
  );
}

class _CovidAppFirebaseWrapper extends StatefulWidget {
  @override
  _CovidAppFirebaseWrapperState createState() =>
      _CovidAppFirebaseWrapperState();
}

class _CovidAppFirebaseWrapperState extends State<_CovidAppFirebaseWrapper> {
  Future<FirebaseApp> _initialization = Firebase.initializeApp();

  void retryInitialization() {
    setState(() {
      _initialization = Firebase.initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return InitializationErrorPage(
              retryInitialization, 'connecting to the Covid Flows database');
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return _CovidAppAuthWrapper();
        }
        return LoadingPage();
      },
    );
  }
}

class _CovidAppAuthWrapper extends StatefulWidget {
  @override
  _CovidAppAuthWrapperState createState() => _CovidAppAuthWrapperState();
}

class _CovidAppAuthWrapperState extends State<_CovidAppAuthWrapper> {
  Future<UserCredential> _credential =
      FirebaseAuth.instance.signInAnonymously();

  void retryAuthentication() {
    setState(() {
      _credential = FirebaseAuth.instance.signInAnonymously();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _credential,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return InitializationErrorPage(
              retryAuthentication, 'authenticating the Covid Flows database');
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Provider.of<CovidTimeseriesModel>(context, listen: false)
              .initialize();
          return _CovidAppTimestampWrapper();
        }
        return LoadingPage();
      },
    );
  }
}

class _CovidAppTimestampWrapper extends StatefulWidget {
  @override
  _CovidAppTimestampWrapperState createState() =>
      _CovidAppTimestampWrapperState();
}

class _CovidAppTimestampWrapperState extends State<_CovidAppTimestampWrapper> {
  final _timestampDocumentPath = 'time-series/World_Timestamp';
  Stream<DocumentSnapshot>? _timestampStream;

  void retryLoad() {
    setState(() {
      _timestampStream =
          FirebaseFirestore.instance.doc(_timestampDocumentPath).snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _timestampStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return InitializationErrorPage(
                retryLoad, 'loading the Covid Flows database');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          }
          return _CovidAppLifeCycleWrapper();
        });
  }
}

class _CovidAppLifeCycleWrapper extends StatefulWidget {
  @override
  _CovidAppLifeCycleWrapperState createState() =>
      _CovidAppLifeCycleWrapperState();
}

class _CovidAppLifeCycleWrapperState extends State<_CovidAppLifeCycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      var pageModel = Provider.of<CovidEntitiesPageModel>(context);
      pageModel.addStar(ModelConstants.startupStarName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CovidApp();
  }
}

class _CovidApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var timeseriesModel =
        Provider.of<CovidTimeseriesModel>(context, listen: false);
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);
    List<List<String>> starPaths = pageModel.getAllModelPaths();
    timeseriesModel.loadEntities(starPaths);
    // TODO: is markStale() needed here?
    Future<void>(timeseriesModel.markStale);
    return MaterialApp(
      title: 'Covid Flows',
      theme: ThemeData(
        primarySwatch: PaletteColors.lightBlueVivid,
      ),
      home: CovidEntitiesPage(title: 'Covid Flows'),
    );
  }
}
