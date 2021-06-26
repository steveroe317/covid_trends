import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import 'date_range_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'compare_covid_chart.dart';

class CompareChartPage extends StatefulWidget {
  final String title;
  final List<List<String>> paths;
  final String seriesName;

  CompareChartPage({Key key, this.title, this.paths, this.seriesName})
      : super(key: key);

  @override
  _CompareChartPageState createState() =>
      _CompareChartPageState(paths, seriesName);
}

class _CompareChartPageState extends State<CompareChartPage> {
  final List<List<String>> paths;
  final String seriesName;

  _CompareChartPageState(this.paths, this.seriesName);

  @override
  Widget build(BuildContext context) {
    return Consumer<CovidEntitiesPageModel>(
        builder: (context, pageModel, child) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title), actions: [
          buildDateRangePopupMenuButton(context),
          buildper100kPopupMenuButton(context),
        ]),
        body: Center(child: CompareChart(paths, seriesName)),
      );
    });
  }
}

class CompareChart extends StatelessWidget {
  final List<List<String>> paths;
  final String seriesName;

  CompareChart(this.paths, this.seriesName);

  @override
  Widget build(BuildContext context) {
    final pageModel = Provider.of<CovidEntitiesPageModel>(context);
    final seriesColors = pageModel.generateColors(paths.length);
    return Padding(
      padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: new CompareCovidChart(paths, seriesName, pageModel.seriesLength,
            pageModel.per100k, seriesColors, true),
      ),
    );
  }
}
