import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import 'covid_chart.dart';
import 'date_range_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'share_button.dart';
import 'star_popup_menu.dart';

class CovidChartPage extends StatelessWidget {
  final String seriesName;

  CovidChartPage({Key? key, required this.seriesName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chartGroupKey = GlobalKey();
    return Consumer<CovidEntitiesPageModel>(
        builder: (context, pageModel, child) {
      return Scaffold(
          appBar: AppBar(actions: [
            buildDateRangePopupMenuButton(context),
            buildper100kPopupMenuButton(context),
            buildStarPopupMenuButton(context),
            buildShareButton(context, chartGroupKey),
          ]),
          body: Center(
              child: RepaintBoundary(
                  key: chartGroupKey,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 8.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.expand(),
                      child: CovidChart(seriesName, true),
                    ),
                  ))));
    });
  }
}
