import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import 'date_range_popup_menu.dart';
import 'simple_covid_chart.dart';

class SimpleChartPage extends StatefulWidget {
  final String title;
  final List<String> path;

  SimpleChartPage({Key key, this.title, this.path}) : super(key: key);

  @override
  _SimpleChartPageState createState() => _SimpleChartPageState(path);
}

class _SimpleChartPageState extends State<SimpleChartPage> {
  final List<String> path;

  _SimpleChartPageState(this.path);

  @override
  Widget build(BuildContext context) {
    return Consumer<CovidEntitiesPageModel>(
        builder: (context, pageModel, child) {
      return Scaffold(
        appBar: AppBar(
            title: Text(widget.title),
            actions: [buildDateRangePopupMenuButton(context)]),
        body: Center(child: SimpleChartGroup(path)),
      );
    });
  }
}

class SimpleChartGroup extends StatelessWidget {
  final List<String> path;

  SimpleChartGroup(this.path);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600 && constraints.maxHeight > 520) {
          return SimpleChartTable(path);
        } else {
          return SimpleChartList(path);
        }
      },
    );
  }
}

class SimpleChartList extends StatelessWidget {
  final List<String> path;

  SimpleChartList(this.path);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _LabelledSimpleCovidChart(path, "Confirmed 7-Day", Colors.black),
        _LabelledSimpleCovidChart(path, "Deaths 7-Day", Colors.red),
        _LabelledSimpleCovidChart(path, "Confirmed", Colors.black),
        _LabelledSimpleCovidChart(path, "Deaths", Colors.red),
      ],
    );
  }
}

class SimpleChartTable extends StatelessWidget {
  final List<String> path;

  SimpleChartTable(this.path);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              _LabelledSimpleCovidChart(path, "Confirmed 7-Day", Colors.black),
              _LabelledSimpleCovidChart(path, "Deaths 7-Day", Colors.red)
            ])),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LabelledSimpleCovidChart(path, "Confirmed", Colors.black),
            _LabelledSimpleCovidChart(path, "Deaths", Colors.red),
          ],
        )),
      ],
    );
  }
}

class _LabelledSimpleCovidChart extends StatelessWidget {
  final List<String> path;
  final String seriesName;
  final Color seriesColor;

  _LabelledSimpleCovidChart(this.path, this.seriesName, this.seriesColor);

  @override
  build(BuildContext context) {
    final pageModel = Provider.of<CovidEntitiesPageModel>(context);
    final regionName = (path.length > 0) ? path.last : '';
    return Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
        child: SizedBox(
          height: 200.0,
          child: new SimpleCovidChart(
              path, seriesName, pageModel.seriesLength, seriesColor),
        ),
      ),
      Center(child: Text('$regionName $seriesName')),
    ]);
  }
}
