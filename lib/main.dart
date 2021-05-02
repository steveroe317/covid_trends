import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'models/covid_timeseries_model.dart';
import 'widgets/simple_covid_chart.dart';

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
      home: MyHomePage(title: 'World Covid Trends'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(
          children: <Widget>[
            LabelledSimpleCovidChart("Confirmed 7-Day"),
            LabelledSimpleCovidChart("Deaths 7-Day"),
            LabelledSimpleCovidChart("Confirmed"),
            LabelledSimpleCovidChart("Deaths"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            Provider.of<CovidTimeseriesModel>(context, listen: false).increment,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class LabelledSimpleCovidChart extends StatelessWidget {
  final String seriesName;

  LabelledSimpleCovidChart(this.seriesName);

  @override
  build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
        child: SizedBox(
          height: 200.0,
          child: new SimpleCovidChart(seriesName),
        ),
      ),
      Center(child: Text(seriesName)),
    ]);
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
