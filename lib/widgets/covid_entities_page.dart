import 'package:covid_trends/widgets/ui_parameters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
import 'compare_region_popup_menu.dart';
import 'covid_chart_group.dart';
import 'covid_chart_group_page.dart';
import 'covid_entity_list.dart';
import 'date_range_popup_menu.dart';
//import 'debug_popup_menu.dart';
import 'navigation_sidebar.dart';
import 'per_100k_popup_menu.dart';
import 'share_button.dart';
import 'sort_popup_menu.dart';
import 'star_popup_menu.dart';
import 'ui_colors.dart';
import 'ui_parameters.dart';

class CovidEntitiesPage extends StatefulWidget {
  CovidEntitiesPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _CovidEntitiesPageState createState() => _CovidEntitiesPageState();
}

class _CovidEntitiesPageState extends State<CovidEntitiesPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 700) {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Wide),
            child: _buildWideScaffold(context, widget.title));
      } else if (constraints.maxWidth >= 350) {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Narrow),
            child: _buildNarrowScaffold(context));
      } else {
        return ChangeNotifierProvider<UiParameters>(
            create: (_) => UiParameters(UiAppShape.Mini),
            child: _buildNarrowScaffold(context));
      }
    });
  }

  Scaffold _buildWideScaffold(BuildContext context, String title) {
    final chartGroupKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          buildSortPopupMenuButton(context),
          buildCompareRegionPopupMenuButton(context),
          buildDateRangePopupMenuButton(context),
          buildper100kPopupMenuButton(context),
          buildStarPopupMenuButton(context),
          buildShareButton(context, chartGroupKey),
          //buildDebugPopupMenuButton(context),
        ],
      ),
      body: _CovidEntitiesWideListBody(chartGroupKey),
      drawer: CovidTrendsNavigationSidebar(),
    );
  }
}

Scaffold _buildNarrowScaffold(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: null,
      actions: [
        buildSortPopupMenuButton(context),
        buildCompareRegionPopupMenuButton(context),
        buildDateRangePopupMenuButton(context),
        buildper100kPopupMenuButton(context),
        buildStarPopupMenuButton(context, openChartPage: true),
        //buildDebugPopupMenuButton(context),
      ],
    ),
    body: _CovidEntitiesNarrowListBody(),
    drawer: CovidTrendsNavigationSidebar(),
  );
}

class _CovidEntitiesWideListBody extends StatelessWidget {
  final Key _chartGroupPage;

  _CovidEntitiesWideListBody(this._chartGroupPage);
  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);
    var uiParameters = context.read<UiParameters>();

    // This onRegionPressed() function does not need the build context,
    // so it can be defined outside build().
    void onRegionPressed(
        CovidTimeseriesModel timeseriesModel, List<String> path) {
      timeseriesModel.loadEntity(path);
      pageModel.setChartPath(path);
    }

    return Row(children: [
      Container(
          width: uiParameters.entityRowWidth,
          color: UiColors.entityListLeaf,
          child: CovidEntityList(onRegionPressed)),
      Expanded(
        child: RepaintBoundary(key: _chartGroupPage, child: CovidChartGroup()),
      )
    ]);
  }
}

class _CovidEntitiesNarrowListBody extends StatelessWidget {
  _CovidEntitiesNarrowListBody();

  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);

    // onRegionPressed() is inside build() so that it has access to the context.
    void onRegionPressed(
        CovidTimeseriesModel timeseriesModel, List<String> path) {
      timeseriesModel.loadEntity(path);
      pageModel.setChartPath(path);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Container(child: CovidChartGroupPage())),
      );
    }

    return Container(
        color: UiColors.entityListLeaf,
        child: CovidEntityList(onRegionPressed));
  }
}
