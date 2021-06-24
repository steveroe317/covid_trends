import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import 'date_range_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'compare_covid_chart.dart';

class MultipleChartPage extends StatefulWidget {
  final String title;
  final List<List<String>> paths;

  MultipleChartPage({Key key, this.title, this.paths}) : super(key: key);

  @override
  _MultipleChartPageState createState() => _MultipleChartPageState(paths);
}

class _MultipleChartPageState extends State<MultipleChartPage> {
  final List<List<String>> paths;

  _MultipleChartPageState(this.paths);

  @override
  Widget build(BuildContext context) {
    return Consumer<CovidEntitiesPageModel>(
        builder: (context, pageModel, child) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: [
          buildDateRangePopupMenuButton(context),
          buildper100kPopupMenuButton(context),
        ]),
        body: Center(child: MultipleChartGroup(paths)),
      );
    });
  }
}

class MultipleChartGroup extends StatelessWidget {
  final List<List<String>> paths;

  MultipleChartGroup(this.paths);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600 && constraints.maxHeight > 520) {
          return MultipleChartTable(paths);
        } else {
          return MultipleChartList(paths);
        }
      },
    );
  }
}

class MultipleChartList extends StatelessWidget {
  final List<List<String>> paths;

  MultipleChartList(this.paths);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _LabelledMultipleCovidChart(paths, "Confirmed 7-Day", Colors.black),
        _LabelledMultipleCovidChart(paths, "Deaths 7-Day", Colors.red),
        _LabelledMultipleCovidChart(paths, "Confirmed", Colors.black),
        _LabelledMultipleCovidChart(paths, "Deaths", Colors.red),
      ],
    );
  }
}

class MultipleChartTable extends StatelessWidget {
  final List<List<String>> paths;

  MultipleChartTable(this.paths);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              _LabelledMultipleCovidChart(
                  paths, "Confirmed 7-Day", Colors.black),
              _LabelledMultipleCovidChart(paths, "Deaths 7-Day", Colors.red)
            ])),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LabelledMultipleCovidChart(paths, "Confirmed", Colors.black),
            _LabelledMultipleCovidChart(paths, "Deaths", Colors.red),
          ],
        )),
      ],
    );
  }
}

class _LabelledMultipleCovidChart extends StatelessWidget {
  final List<List<String>> paths;
  final String seriesName;
  final Color seriesColor;

  _LabelledMultipleCovidChart(this.paths, this.seriesName, this.seriesColor);

  @override
  build(BuildContext context) {
    final pageModel = Provider.of<CovidEntitiesPageModel>(context);
    final scaleSuffix = (pageModel.per100k) ? ' per 100k' : '';
    final seriesColors = generateColors(paths.length);
    return Column(children: [
      Padding(
          padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
          child: SizedBox(
            height: 200.0,
            child: new MultipleCovidChart(paths, seriesName,
                pageModel.seriesLength, pageModel.per100k, seriesColors),
          )),
      Center(child: Text('$seriesName$scaleSuffix')),
    ]);
  }

  List<Color> generateColors(int count) {
    var colors = <Color>[];
    var hue = 240.0;
    const double hueStep = 77.0;
    for (var index = 0; index < count; ++index) {
      var hslColor = HSLColor.fromAHSL(1.0, hue, 0.5, 0.5);
      colors.add(hslColor.toColor());
      hue += hueStep;
      if (hue > 360.0) {
        hue -= 360;
      }
    }
    return colors;
  }
}
