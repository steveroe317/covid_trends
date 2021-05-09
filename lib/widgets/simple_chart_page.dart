import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'simple_covid_chart.dart';

class SimpleChartPage extends StatefulWidget {
  SimpleChartPage({Key key, this.title, this.path}) : super(key: key);
  final String title;
  final List<String> path;

  @override
  _SimpleChartPageState createState() => _SimpleChartPageState(path);
}

class _SimpleChartPageState extends State<SimpleChartPage> {
  final List<String> path;

  _SimpleChartPageState(this.path);

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
            _LabelledSimpleCovidChart(path, "Confirmed 7-Day", Colors.black),
            _LabelledSimpleCovidChart(path, "Deaths 7-Day", Colors.red),
            _LabelledSimpleCovidChart(path, "Confirmed", Colors.black),
            _LabelledSimpleCovidChart(path, "Deaths", Colors.red),
          ],
        ),
      ),
    );
  }
}

class _LabelledSimpleCovidChart extends StatelessWidget {
  final String seriesName;
  final Color seriesColor;
  final List<String> path;

  _LabelledSimpleCovidChart(this.path, this.seriesName, this.seriesColor);

  @override
  build(BuildContext context) {
    final regionName = (path.length > 0) ? path.last : '';
    return Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
        child: SizedBox(
          height: 200.0,
          child: new SimpleCovidChart(path, seriesName, seriesColor),
        ),
      ),
      Center(child: Text('$regionName $seriesName')),
    ]);
  }
}
