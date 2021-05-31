import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
import 'simple_chart_page.dart';

enum _CovidEntityListItemDepth { root, stem, leaf }

class _CovidEntityListConsts {
  static const buttonWidth = 200.0;
  static const metricWidth = 120.0;
  static const noMetricName = 'Name';
}

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
        actions: [buildSortPopupMenuButton(context)],
      ),
      body: CovidEntityList(),
    );
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
          var metricNames = timeseriesModel.sortMetrics();
          var pageModel =
              Provider.of<CovidEntitiesPageModel>(context, listen: false);
          metricNames.sort();
          metricNames.insert(0, _CovidEntityListConsts.noMetricName);
          return List<PopupMenuEntry<String>>.from(metricNames.map((name) =>
              CheckedPopupMenuItem(
                  value: name,
                  child: Text(name),
                  checked: name == pageModel.sortMetric)));
        });
  }
}

class CovidEntityList extends StatelessWidget {
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
      entityList.add(EntityListItem(
          path, depth, pageModel, timeseriesModel, numberFormatter));
    }

    if (currentPath.length > 0) {
      entityList.add(Divider());
    }

    entityList.addAll(List<Widget>.from(childNames.map((name) => EntityListItem(
        [...currentPath, name],
        _CovidEntityListItemDepth.leaf,
        pageModel,
        timeseriesModel,
        numberFormatter))));

    return Column(
      children: [
        Container(
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
    return Row(
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
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
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
            child: Text(
                (_pageModel.sortMetric != _CovidEntityListConsts.noMetricName)
                    ? _pageModel.sortMetric
                    : ''),
          ),
        ),
      ],
    );
  }
}

class EntityListItem extends StatelessWidget {
  final List<String> _path;
  final _CovidEntityListItemDepth _depth;
  final CovidTimeseriesModel _timeseriesModel;
  final CovidEntitiesPageModel _pageModel;
  final numberFormatter;

  EntityListItem(this._path, this._depth, this._pageModel,
      this._timeseriesModel, this.numberFormatter);

  @override
  build(BuildContext context) {
    return Row(
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
            onPressed: () {
              _timeseriesModel.loadEntity(_path);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SimpleChartPage(
                        title: '${_path.last} Covid Trends', path: _path)),
              );
            },
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
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
            child: Text(_sortMetricValueString()),
          ),
        ),
      ],
    );
  }

  void _openParentPath() {
    _pageModel.setPath(_path.sublist(0, _path.length - 1));
  }

  void _openPath() {
    _timeseriesModel.loadEntity(_path);
    _pageModel.setPath(_path);
  }

  String _sortMetricValueString() {
    String sortMetric = _pageModel.sortMetric;
    var metricValue = _timeseriesModel.entitySortMetric(_path, sortMetric);
    return (metricValue != 0) ? numberFormatter.format(metricValue) : '';
  }
}
