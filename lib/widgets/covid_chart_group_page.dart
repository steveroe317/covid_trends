import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import 'covid_chart_group.dart';
import 'date_range_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'share_button.dart';
import 'star_popup_menu.dart';

class CovidChartGroupPage extends StatefulWidget {
  CovidChartGroupPage({Key? key}) : super(key: key);

  @override
  _CovidChartGroupPageState createState() => _CovidChartGroupPageState();
}

class _CovidChartGroupPageState extends State<CovidChartGroupPage> {
  final chartGroupKey = GlobalKey();

  _CovidChartGroupPageState();

  @override
  Widget build(BuildContext context) {
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
            child:
                RepaintBoundary(key: chartGroupKey, child: CovidChartGroup()),
          ));
    });
  }
}
