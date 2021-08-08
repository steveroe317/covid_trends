import 'package:cloud_firestore/cloud_firestore.dart';
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
    ], child: CovidAppAuthWrapper()),
  );
}

class CovidAppAuthWrapper extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return InitializationErrorPage();
        }
        if (snapshot.connectionState == ConnectionState.done) {
          FirebaseAuth auth = FirebaseAuth.instance;
          auth.signInAnonymously();
          Provider.of<CovidTimeseriesModel>(context, listen: false)
              .initialize();
          return CovidAppTimestampWrapper();
        }
        return LoadingPage();
      },
    );
  }
}

class CovidAppTimestampWrapper extends StatefulWidget {
  @override
  _CovidAppTimestampWrapperState createState() =>
      _CovidAppTimestampWrapperState();
}

class _CovidAppTimestampWrapperState extends State<CovidAppTimestampWrapper> {
  final Stream<DocumentSnapshot> _timestampStream =
      FirebaseFirestore.instance.doc('time-series/Timestamp').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _timestampStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return InitializationErrorPage();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          }
          var timeseriesModel =
              Provider.of<CovidTimeseriesModel>(context, listen: false);
          Future<void>(timeseriesModel.markStale);
          return MaterialApp(
            title: 'Covid Trends',
            theme: ThemeData(
              primarySwatch: PaletteColors.lightBlueVivid,
            ),
            home: CovidEntitiesPage(title: 'Covid Trends'),
          );
        });
  }
}
