import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/covid_timeseries_model.dart';
import 'widgets/simple_chart_page.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';

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
          return CircularProgressIndicator(backgroundColor: Colors.red);
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Provider.of<CovidTimeseriesModel>(context, listen: false)
              .initialize();
          return buildMaterialApp();
        }
        return CircularProgressIndicator(backgroundColor: Colors.green);
      },
    );
  }

  MaterialApp buildMaterialApp() {
    return MaterialApp(
      title: 'Covid Trends',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SimpleChartPage(title: 'Covid Trends'),
    );
  }
}

class LoadingPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Loading')),
    );
  }
}

class InitializationErrorPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Error initializing Firebase')),
    );
  }
}
