import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'simple_covid_chart.dart';

class SimpleChartPage extends StatefulWidget {
  final String title;
  final List<String> path;
  final int seriesLength;

  SimpleChartPage({Key key, this.title, this.path, this.seriesLength})
      : super(key: key);

  @override
  _SimpleChartPageState createState() =>
      _SimpleChartPageState(path, seriesLength);
}

class _SimpleChartPageState extends State<SimpleChartPage> {
  final List<String> path;
  final int seriesLength;

  _SimpleChartPageState(this.path, this.seriesLength);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(child: SimpleChartGroup(path, seriesLength)),
    );
  }
}

class SimpleChartGroup extends StatelessWidget {
  final List<String> path;
  final int seriesLength;

  SimpleChartGroup(this.path, this.seriesLength);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _LabelledSimpleCovidChart(
            path, "Confirmed 7-Day", seriesLength, Colors.black),
        _LabelledSimpleCovidChart(
            path, "Deaths 7-Day", seriesLength, Colors.red),
        _LabelledSimpleCovidChart(
            path, "Confirmed", seriesLength, Colors.black),
        _LabelledSimpleCovidChart(path, "Deaths", seriesLength, Colors.red),
      ],
    );
  }
}

class _LabelledSimpleCovidChart extends StatelessWidget {
  final List<String> path;
  final String seriesName;
  final Color seriesColor;
  final int seriesLength;

  _LabelledSimpleCovidChart(
      this.path, this.seriesName, this.seriesLength, this.seriesColor);

  @override
  build(BuildContext context) {
    final regionName = (path.length > 0) ? path.last : '';
    return Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
        child: SizedBox(
          height: 200.0,
          child:
              new SimpleCovidChart(path, seriesName, seriesLength, seriesColor),
        ),
      ),
      Center(child: Text('$regionName $seriesName')),
    ]);
  }
}
