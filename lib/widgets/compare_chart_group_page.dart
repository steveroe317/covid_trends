import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import 'date_range_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'compare_covid_chart.dart';

class CompareChartGroupPage extends StatefulWidget {
  final String title;
  final List<List<String>> paths;

  CompareChartGroupPage({Key key, this.title, this.paths}) : super(key: key);

  @override
  _CompareChartGroupPageState createState() =>
      _CompareChartGroupPageState(paths);
}

class _CompareChartGroupPageState extends State<CompareChartGroupPage> {
  final List<List<String>> paths;

  _CompareChartGroupPageState(this.paths);

  @override
  Widget build(BuildContext context) {
    return Consumer<CovidEntitiesPageModel>(
        builder: (context, pageModel, child) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: [
          buildDateRangePopupMenuButton(context),
          buildper100kPopupMenuButton(context),
        ]),
        body: Center(child: CompareChartGroup(paths)),
      );
    });
  }
}

class CompareChartGroup extends StatelessWidget {
  final List<List<String>> paths;

  CompareChartGroup(this.paths);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600 && constraints.maxHeight > 520) {
          return CompareChartTable(paths);
        } else {
          return CompareChartList(paths);
        }
      },
    );
  }
}

class CompareChartList extends StatelessWidget {
  final List<List<String>> paths;

  CompareChartList(this.paths);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _LabelledCompareCovidChart(paths, "Confirmed 7-Day", Colors.black),
        _LabelledCompareCovidChart(paths, "Deaths 7-Day", Colors.red),
        _LabelledCompareCovidChart(paths, "Confirmed", Colors.black),
        _LabelledCompareCovidChart(paths, "Deaths", Colors.red),
      ],
    );
  }
}

class CompareChartTable extends StatelessWidget {
  final List<List<String>> paths;

  CompareChartTable(this.paths);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              _LabelledCompareCovidChart(
                  paths, "Confirmed 7-Day", Colors.black),
              _LabelledCompareCovidChart(paths, "Deaths 7-Day", Colors.red)
            ])),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LabelledCompareCovidChart(paths, "Confirmed", Colors.black),
            _LabelledCompareCovidChart(paths, "Deaths", Colors.red),
          ],
        )),
      ],
    );
  }
}

class _LabelledCompareCovidChart extends StatelessWidget {
  final List<List<String>> paths;
  final String seriesName;
  final Color seriesColor;

  _LabelledCompareCovidChart(this.paths, this.seriesName, this.seriesColor);

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
            child: new CompareCovidChart(paths, seriesName,
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
