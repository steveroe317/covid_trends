import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_timeseries_model.dart';
import 'simple_chart_page.dart';

class CovidEntitiesPage extends StatefulWidget {
  CovidEntitiesPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CovidEntitiesPageState createState() => _CovidEntitiesPageState();
}

class _CovidEntitiesPageState extends State<CovidEntitiesPage> {
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
      body: CovidEntityList(),
    );
  }
}

class CovidEntityList extends StatelessWidget {
  @override
  build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var subEntityNames = timeseriesModel.subEntityNames;
    final currentPath = timeseriesModel.path;
    var entityList = List<Widget>.from(subEntityNames.map((x) => TextButton(
        onPressed: () {
          timeseriesModel.openSubEntity(x);
        },
        onLongPress: () {
          final List<String> path = [...currentPath, x];
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    SimpleChartPage(title: '$x Covid Trends', path: path)),
          );
        },
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black)),
        child: Text(x, style: Theme.of(context).textTheme.headline6))));
    if (currentPath.length > 0) {
      entityList.insert(0, Divider());
    }
    for (var index = currentPath.length - 1; index >= 0; --index) {
      final name = currentPath[index];
      final path = currentPath.sublist(0, index + 1);
      entityList.insert(
          0,
          TextButton(
              onPressed: () {
                timeseriesModel.openPath(path);
              },
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SimpleChartPage(
                          title: '$name Covid Trends', path: path)),
                );
              },
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black)),
              child: Text(name, style: Theme.of(context).textTheme.headline6)));
    }
    return ListView(children: entityList);
  }
}
