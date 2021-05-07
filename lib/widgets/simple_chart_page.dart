import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_timeseries_model.dart';
import 'simple_covid_chart.dart';

class SimpleChartPage extends StatefulWidget {
  SimpleChartPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SimpleChartPageState createState() => _SimpleChartPageState();
}

class _SimpleChartPageState extends State<SimpleChartPage> {
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
            LabelledSimpleCovidChart("Confirmed 7-Day", Colors.black),
            LabelledSimpleCovidChart("Deaths 7-Day", Colors.red),
            LabelledSimpleCovidChart("Confirmed", Colors.black),
            LabelledSimpleCovidChart("Deaths", Colors.red),
          ],
        ),
      ),
      drawer: CovidSubEntityList(),
    );
  }
}

class LabelledSimpleCovidChart extends StatelessWidget {
  final String seriesName;
  final Color seriesColor;

  LabelledSimpleCovidChart(this.seriesName, this.seriesColor);

  @override
  build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    final path = timeseriesModel.path;
    final regionName = (path.length > 0) ? path.last : '';
    return Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
        child: SizedBox(
          height: 200.0,
          child: new SimpleCovidChart(seriesName, seriesColor),
        ),
      ),
      Center(child: Text('$regionName $seriesName')),
    ]);
  }
}

class CovidSubEntityList extends StatelessWidget {
  @override
  build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var subEntityNames = timeseriesModel.subEntityNames;
    var subEntityButtons = List<TextButton>.from(subEntityNames.map((x) =>
        TextButton(
            onPressed: () {
              timeseriesModel.openSubEntity(x);
            },
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white)),
            child: Text(x))));
    if (timeseriesModel.parent != null) {
      var path = timeseriesModel.path;
      if (path.length > 1) {
        var parentName = path[path.length - 2];
        subEntityButtons.insert(
            0,
            TextButton(
                onPressed: () {
                  timeseriesModel.openParent();
                },
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white)),
                child: Text(parentName)));
      }
    }
    return ListView(children: subEntityButtons);
  }
}
