import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import 'covid_chart.dart';
import 'covid_chart_page.dart';

class CovidChartGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // TODO: Move these constants into ui_constants.dart.
        if (constraints.maxWidth > 600 && constraints.maxHeight > 520) {
          return CovidChartTable();
        } else {
          return CovidChartList();
        }
      },
    );
  }
}

class CovidChartList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        _LabelledCovidChart("Confirmed 7-Day"),
        _LabelledCovidChart("Deaths 7-Day"),
        _LabelledCovidChart("Confirmed"),
        _LabelledCovidChart("Deaths"),
      ],
    );
  }
}

class CovidChartTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
              _LabelledCovidChart("Confirmed 7-Day"),
              _LabelledCovidChart("Deaths 7-Day"),
            ])),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _LabelledCovidChart("Confirmed"),
            _LabelledCovidChart("Deaths"),
          ],
        )),
      ],
    );
  }
}

class _LabelledCovidChart extends StatelessWidget {
  final String seriesName;

  _LabelledCovidChart(this.seriesName);

  @override
  build(BuildContext context) {
    final pageModel = Provider.of<CovidEntitiesPageModel>(context);
    final scaleSuffix = (pageModel.per100k) ? ' per 100k' : '';
    var paths = (pageModel.compareRegion)
        ? pageModel.pathList
        : [pageModel.chartPath()];
    var regionName = (paths.length == 1 && paths.first.length > 0)
        ? '${paths.first.last} '
        : '';
    return Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
        child: SizedBox(
          height: 200.0,
          child: new CovidChart(seriesName, false),
        ),
      ),
      InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CovidChartPage(seriesName: seriesName)),
          );
        },
        child: Center(
            child: Text('$regionName$seriesName$scaleSuffix',
                style: TextStyle(fontWeight: FontWeight.w600))),
      )
    ]);
  }
}
