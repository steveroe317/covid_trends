import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import 'compare_chart_page.dart';
import 'compare_covid_chart.dart';
import 'date_range_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'share_button.dart';
import 'star_popup_menu.dart';

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
  final chartGroupKey = GlobalKey();

  _CompareChartGroupPageState(this.paths);

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
                key: chartGroupKey, child: CompareChartGroup(paths)),
          ));
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
        _LabelledCompareCovidChart(paths, "Confirmed 7-Day"),
        _LabelledCompareCovidChart(paths, "Deaths 7-Day"),
        _LabelledCompareCovidChart(paths, "Confirmed"),
        _LabelledCompareCovidChart(paths, "Deaths"),
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
              _LabelledCompareCovidChart(paths, "Confirmed 7-Day"),
              _LabelledCompareCovidChart(paths, "Deaths 7-Day")
            ])),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LabelledCompareCovidChart(
              paths,
              "Confirmed",
            ),
            _LabelledCompareCovidChart(paths, "Deaths"),
          ],
        )),
      ],
    );
  }
}

class _LabelledCompareCovidChart extends StatelessWidget {
  final List<List<String>> paths;
  final String seriesName;

  _LabelledCompareCovidChart(this.paths, this.seriesName);

  @override
  build(BuildContext context) {
    final pageModel = Provider.of<CovidEntitiesPageModel>(context);
    final scaleSuffix = (pageModel.per100k) ? ' per 100k' : '';
    final seriesColors = pageModel.generateColors(paths.length);
    return Column(children: [
      Padding(
          padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
          child: SizedBox(
            height: 200.0,
            child: new CompareCovidChart(paths, seriesName,
                pageModel.seriesLength, pageModel.per100k, seriesColors, false),
          )),
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CompareChartPage(
                    title: 'Compare Covid Trends',
                    paths: paths,
                    seriesName: seriesName)),
          );
        },
        child: Center(
            child: Text(
          '$seriesName$scaleSuffix',
          style: TextStyle(fontWeight: FontWeight.w600),
        )),
      )
    ]);
  }
}
