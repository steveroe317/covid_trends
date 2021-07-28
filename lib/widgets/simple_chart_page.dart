import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import 'date_range_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'share_button.dart';
import 'simple_covid_chart.dart';
import 'star_popup_menu.dart';

class SimpleChartPage extends StatefulWidget {
  final String title;
  final List<String> path;
  final String seriesName;
  final Color seriesColor;

  SimpleChartPage(
      {Key key, this.title, this.path, this.seriesName, this.seriesColor})
      : super(key: key);

  @override
  _SimpleChartPageState createState() =>
      _SimpleChartPageState(path, seriesName, seriesColor);
}

class _SimpleChartPageState extends State<SimpleChartPage> {
  final List<String> path;
  final String seriesName;
  final Color seriesColor;
  final chartGroupKey = GlobalKey();

  _SimpleChartPageState(this.path, this.seriesName, this.seriesColor);

  @override
  Widget build(BuildContext context) {
    return Consumer<CovidEntitiesPageModel>(
        builder: (context, pageModel, child) {
      return Scaffold(
          appBar: AppBar(title: Text(widget.title), actions: [
            buildDateRangePopupMenuButton(context),
            buildper100kPopupMenuButton(context),
            buildStarPopupMenuButton(context),
            buildShareButton(context, chartGroupKey),
          ]),
          body: Center(
            child: RepaintBoundary(
                key: chartGroupKey,
                child: SimpleChart(path, seriesName, seriesColor)),
          ));
    });
  }
}

class SimpleChart extends StatelessWidget {
  final List<String> path;
  final String seriesName;
  final Color seriesColor;

  SimpleChart(this.path, this.seriesName, this.seriesColor);

  @override
  Widget build(BuildContext context) {
    final pageModel = Provider.of<CovidEntitiesPageModel>(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: new SimpleCovidChart(path, seriesName, pageModel.seriesLength,
            pageModel.per100k, seriesColor, true),
      ),
    );
  }
}
