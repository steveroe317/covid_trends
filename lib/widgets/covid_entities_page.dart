import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
import 'simple_chart_page.dart';

enum _CovidEntityListItemDepth { root, stem, leaf }

class _CovidEntityListConsts {
  static const buttonWidth = 170.0;
  static const metricWidth = 120.0;
  static const iconWidth = 24.0;
  static const entityRowWidth = buttonWidth + metricWidth + iconWidth + 24 + 12;
  static const noMetricName = 'Name';
  static const defaultMetric = 'Confirmed 7-Day';
}

class CovidEntitiesPage extends StatefulWidget {
  CovidEntitiesPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CovidEntitiesPageState createState() => _CovidEntitiesPageState();
}

class _CovidEntitiesPageState extends State<CovidEntitiesPage> {
  var _timeseriesModel;

  @override
  Widget build(BuildContext context) {
    _timeseriesModel =
        Provider.of<CovidTimeseriesModel>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            buildSortPopupMenuButton(context),
            buildDateRangePopupMenuButton(context),
            buildDebugPopupMenuButton(context)
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

  PopupMenuButton<String> buildSortPopupMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
        icon: const Icon(Icons.sort),
        tooltip: 'Sort By',
        onSelected: (String sortMetric) {
          var pageModel =
              Provider.of<CovidEntitiesPageModel>(context, listen: false);
          pageModel.sortMetric = sortMetric;
        },
        itemBuilder: (BuildContext context) {
          var timeseriesModel =
              Provider.of<CovidTimeseriesModel>(context, listen: false);
          var pageModel =
              Provider.of<CovidEntitiesPageModel>(context, listen: false);
          var metricNames = timeseriesModel.sortMetrics();
          metricNames.sort();
          metricNames.insert(0, _CovidEntityListConsts.noMetricName);
          return List<PopupMenuEntry<String>>.from(metricNames.map((name) =>
              CheckedPopupMenuItem(
                  value: name,
                  child: Text(name),
                  checked: name == pageModel.sortMetric)));
        });
  }

  PopupMenuButton<int> buildDateRangePopupMenuButton(BuildContext context) {
    return PopupMenuButton<int>(
        icon: const Icon(Icons.date_range),
        tooltip: 'Date Range',
        onSelected: (int seriesLength) {
          var pageModel =
              Provider.of<CovidEntitiesPageModel>(context, listen: false);
          pageModel.setSeriesLength(seriesLength);
        },
        itemBuilder: (BuildContext context) {
          var pageModel =
              Provider.of<CovidEntitiesPageModel>(context, listen: false);
          return List<PopupMenuEntry<int>>.from([0, 240, 120, 60].map(
            (days) => CheckedPopupMenuItem(
                child: Text(days == 0 ? 'All' : '$days Days'),
                value: days,
                checked: days == pageModel.seriesLength),
          ));
        });
  }

  PopupMenuButton<String> buildDebugPopupMenuButton(BuildContext context) {
    return PopupMenuButton<String>(
        icon: const Icon(Icons.plumbing),
        tooltip: 'Internal testing',
        onSelected: (String debugAction) {
          if (debugAction == 'Halve History') {
            _timeseriesModel.halveHistory();
          } else if (debugAction == 'Refresh') {
            _timeseriesModel.markStale();
          }
        },
        itemBuilder: (BuildContext context) {
          var debugActions = List<String>.from(['Halve History', 'Refresh']);
          return List<PopupMenuEntry<String>>.from(debugActions
              .map((name) => PopupMenuItem(value: name, child: Text(name))));
        });
  }
}

class _CovidEntitiesNarrowPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);

    // The function onRegionPressed() is defined inside build() so that it has
    // access to build()'s context.
    void Function(CovidTimeseriesModel, List<String>) onRegionPressed(
        CovidTimeseriesModel timeseriesModel, List<String> path) {
      timeseriesModel.loadEntity(path);
      pageModel.setChartPath(path);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SimpleChartPage(
                  title: '${path.last} Covid Trends',
                  path: path,
                  seriesLength: pageModel.seriesLength,
                )),
      );
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
      return null;
    }

    return Row(children: [
      SizedBox(
          width: _CovidEntityListConsts.entityRowWidth,
          child: CovidEntityList(onRegionPressed)),
      Expanded(
          child:
              SimpleChartGroup(pageModel.chartPath(), pageModel.seriesLength)),
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
        sortBy: pageModel.sortMetric, sortUp: false);
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
          child: EntityListHeader(pageModel),
        ),
        Container(child: Divider()),
        Expanded(child: ListView(children: entityList)),
      ],
    );
  }
}

class EntityListHeader extends StatelessWidget {
  final CovidEntitiesPageModel _pageModel;

  EntityListHeader(this._pageModel);

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
                child: Text((_pageModel.sortMetric !=
                        _CovidEntityListConsts.noMetricName)
                    ? _pageModel.sortMetric
                    : _CovidEntityListConsts.defaultMetric),
              ),
            ),
          ],
        ));
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

  void _openParentPath() {
    _pageModel.setPath(_path.sublist(0, _path.length - 1));
  }

  void _openPath() {
    _timeseriesModel.loadEntity(_path);
    _pageModel.setPath(_path);
  }

  String _metricValueString() {
    String displayMetric = _pageModel.sortMetric;
    if (displayMetric == _CovidEntityListConsts.noMetricName) {
      displayMetric = _CovidEntityListConsts.defaultMetric;
    }
    var metricValue = _timeseriesModel.entitySortMetric(_path, displayMetric);
    return (metricValue != 0) ? numberFormatter.format(metricValue) : '';
  }
}
