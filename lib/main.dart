import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/covid_timeseries_model.dart';
import 'widgets/covid_entities_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
        create: (context) => CovidTimeseriesModel(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
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
          Provider.of<CovidTimeseriesModel>(context, listen: false)
              .initialize();
          return buildMaterialApp();
        }
        return LoadingPage();
      },
    );
  }

  MaterialApp buildMaterialApp() {
    return MaterialApp(
      title: 'Covid Trends',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CovidEntitiesPage(title: 'Covid Trends'),
    );
  }
}

class LoadingPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    return Container(
        color: Colors.grey,
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Loading Covid Trends',
                  textDirection: TextDirection.ltr, textScaleFactor: 2.0)),
          Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                  backgroundColor: Colors.blue.shade200)),
        ])));
  }
}

class InitializationErrorPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Center(
          child: Text('Error loading Covid Trends',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              textScaleFactor: 2.0,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
    );
  }
}
