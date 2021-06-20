import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
import 'date_range_popup_menu.dart';
//import 'debug_popup_menu.dart';
import 'multiple_region_popup_menu.dart';
import 'per_100k_popup_menu.dart';
import 'simple_chart_page.dart';
import 'multiple_chart_page.dart';
import 'sort_popup_menu.dart';

class _CovidEntityListConsts {
  static const buttonWidth = 170.0;
  static const metricWidth = 120.0;
  static const iconWidth = 24.0;
  static const entityRowWidth = buttonWidth + metricWidth + iconWidth + 24 + 12;
  static const defaultDisplayMetric = 'Confirmed 7-Day';
}

enum _CovidEntityListItemDepth { root, stem, leaf }

class CovidEntitiesPage extends StatefulWidget {
  CovidEntitiesPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CovidEntitiesPageState createState() => _CovidEntitiesPageState();
}

class _CovidEntitiesPageState extends State<CovidEntitiesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            buildSortPopupMenuButton(context),
            buildMultipleRegionPopupMenuButton(context),
            buildDateRangePopupMenuButton(context),
            buildper100kPopupMenuButton(context),
            //buildDebugPopupMenuButton(context),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 700) {
              return _CovidEntitiesWidePage();
            } else {
              return _CovidEntitiesNarrowPage();
            }
          },
        ));
  }
}

class _CovidEntitiesNarrowPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);

    // onRegionPressed() is inside build() so that it has access to the context.
    void Function(CovidTimeseriesModel, List<String>) onRegionPressed(
        CovidTimeseriesModel timeseriesModel, List<String> path) {
      timeseriesModel.loadEntity(path);
      pageModel.setChartPath(path);
      pageModel.addPathList(path);
      if (pageModel.multipleRegion) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MultipleChartPage(
                    title: '${path.last} Covid Trends',
                    paths: pageModel.pathList,
                  )),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SimpleChartPage(
                    title: '${path.last} Covid Trends',
                    path: path,
                  )),
        );
      }
      return null;
    }

    return CovidEntityList(onRegionPressed);
  }
}

class _CovidEntitiesWidePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);

    // This onRegionPressed() function does not need the build context,
    // so it can be defined outside build().
    void Function(CovidTimeseriesModel, List<String>) onRegionPressed(
        CovidTimeseriesModel timeseriesModel, List<String> path) {
      timeseriesModel.loadEntity(path);
      pageModel.setChartPath(path);
      pageModel.addPathList(path);
      return null;
    }

    return Row(children: [
      SizedBox(
          width: _CovidEntityListConsts.entityRowWidth,
          child: CovidEntityList(onRegionPressed)),
      Expanded(
          child: (pageModel.multipleRegion)
              ? MultipleChartGroup(pageModel.pathList)
              : SimpleChartGroup(pageModel.chartPath())),
    ]);
  }
}

class CovidEntityList extends StatelessWidget {
  final void Function(CovidTimeseriesModel, List<String>) _onRegionPressed;

  CovidEntityList(this._onRegionPressed);

  @override
  build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);
    final childNames = timeseriesModel.entityChildNames(pageModel.path(),
        sortBy: pageModel.sortMetric,
        sortUp: false,
        per100k: pageModel.per100k);
    final currentPath = pageModel.path();
    final numberFormatter = NumberFormat('#,###');

    List<Widget> entityList = [];

    for (var index = 0; index < currentPath.length; ++index) {
      final path = currentPath.sublist(0, index + 1);
      var depth = (index == 0)
          ? _CovidEntityListItemDepth.root
          : _CovidEntityListItemDepth.stem;
      entityList.add(EntityListItem(path, depth, _onRegionPressed, pageModel,
          timeseriesModel, numberFormatter));
    }

    if (currentPath.length > 0) {
      entityList.add(Divider());
    }

    entityList.addAll(List<Widget>.from(childNames.map((name) => EntityListItem(
        [...currentPath, name],
        _CovidEntityListItemDepth.leaf,
        _onRegionPressed,
        pageModel,
        timeseriesModel,
        numberFormatter))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _CovidEntityListConsts.entityRowWidth,
          child: EntityListHeader(pageModel, timeseriesModel),
        ),
        Container(child: Divider()),
        Expanded(child: ListView(children: entityList)),
      ],
    );
  }
}

class EntityListHeader extends StatelessWidget {
  final CovidEntitiesPageModel _pageModel;
  final CovidTimeseriesModel _timeseriesModel;

  EntityListHeader(this._pageModel, this._timeseriesModel);

  @override
  build(BuildContext context) {
    return SizedBox(
        width: _CovidEntityListConsts.entityRowWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Opacity(
              opacity: 0.0,
              child: IconButton(
                icon: Icon(Icons.expand_more),
                onPressed: () {},
              ),
            ),
            SizedBox(
              width: _CovidEntityListConsts.buttonWidth,
              child: TextButton(
                onPressed: () {},
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    alignment: AlignmentDirectional(0, 0)),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Region',
                        style: Theme.of(context).textTheme.headline6)),
              ),
            ),
            SizedBox(
              width: _CovidEntityListConsts.metricWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(_sortMetricName()),
              ),
            ),
          ],
        ));
  }

  String _sortMetricName() {
    var name = (_pageModel.sortMetric != _timeseriesModel.noSortMetricName)
        ? _pageModel.sortMetric
        : _CovidEntityListConsts.defaultDisplayMetric;
    if (_pageModel.per100k) {
      name = '$name\nper 100,000';
    }
    return name;
  }
}

class EntityListItem extends StatelessWidget {
  final List<String> _path;
  final _CovidEntityListItemDepth _depth;
  final void Function(CovidTimeseriesModel, List<String>) _onRegionPressed;
  final CovidTimeseriesModel _timeseriesModel;
  final CovidEntitiesPageModel _pageModel;
  final numberFormatter;

  EntityListItem(this._path, this._depth, this._onRegionPressed,
      this._pageModel, this._timeseriesModel, this.numberFormatter);

  void onRegionPressed() {
    return _onRegionPressed(_timeseriesModel, _path);
  }

  @override
  build(BuildContext context) {
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);
    return Container(
        width: _CovidEntityListConsts.entityRowWidth,
        color: listEquals(_path, pageModel.chartPath()) ? Colors.black12 : null,
        padding: EdgeInsets.only(left: 6, right: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Opacity(
              opacity: (_depth != _CovidEntityListItemDepth.root &&
                      _timeseriesModel.entityHasChildren(_path))
                  ? 1.0
                  : 0.0,
              child: IconButton(
                  icon: Icon(_depth == _CovidEntityListItemDepth.leaf
                      ? Icons.expand_more
                      : Icons.expand_less),
                  onPressed: (_depth == _CovidEntityListItemDepth.stem)
                      ? _openParentPath
                      : (_depth == _CovidEntityListItemDepth.leaf &&
                              _timeseriesModel.entityHasChildren(_path))
                          ? _openPath
                          : null),
            ),
            SizedBox(
              width: _CovidEntityListConsts.buttonWidth,
              child: TextButton(
                onPressed: onRegionPressed,
                onLongPress: onRegionLongPress,
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    alignment: AlignmentDirectional(0, 0)),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_path.last,
                        style: Theme.of(context).textTheme.headline6)),
              ),
            ),
            SizedBox(
              width: _CovidEntityListConsts.metricWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(_metricValueString()),
              ),
            ),
          ],
        ));
  }

  void onRegionLongPress() {
    _pageModel.clearPathList();
    onRegionPressed();
  }

  void _openParentPath() {
    _pageModel.setPath(_path.sublist(0, _path.length - 1));
  }

  void _openPath() {
    _timeseriesModel.loadEntity(_path);
    _pageModel.setPath(_path);
  }

  String _metricValueString() {
    String displayMetric = _pageModel.sortMetric;
    if (displayMetric == _timeseriesModel.noSortMetricName) {
      displayMetric = _CovidEntityListConsts.defaultDisplayMetric;
    }
    var metricValue = _timeseriesModel.entitySortMetric(
        _path, displayMetric, _pageModel.per100k);
    return (metricValue != 0) ? numberFormatter.format(metricValue) : '';
  }
}
