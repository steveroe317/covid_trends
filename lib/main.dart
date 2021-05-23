import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/covid_timeseries_model.dart';
import 'widgets/covid_entities_page.dart';
import 'widgets/initialization_error_page.dart';
import 'widgets/loading_page.dart';

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
