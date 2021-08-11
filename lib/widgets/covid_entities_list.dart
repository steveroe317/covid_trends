import 'package:covid_trends/widgets/ui_parameters.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
//import 'debug_popup_menu.dart';
import 'ui_colors.dart';
import 'ui_constants.dart';
import 'ui_parameters.dart';

enum _CovidEntityListItemDepth { root, stem, leaf }

class CovidEntityList extends StatelessWidget {
  final void Function(CovidTimeseriesModel, List<String>) _onRegionPressed;

  CovidEntityList(this._onRegionPressed);

  @override
  build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var pageModel = Provider.of<CovidEntitiesPageModel>(context);
    var uiParameters = context.watch<UiParameters>();
    final childNames = timeseriesModel.entityChildNames(
        pageModel.entityPagePath(),
        sortBy: pageModel.sortMetric,
        sortUp: false,
        per100k: pageModel.per100k);
    final currentPath = pageModel.entityPagePath();
    final numberFormatter = NumberFormat('#,###');

    // Build base of the entity list with the parent entities.
    List<Widget> stemEntityList = [
      Row(children: [
        Expanded(
            child: Container(
          width: uiParameters.entityRowWidth,
          color: UiColors.entityListHeader,
          child: EntityListHeader(pageModel),
        ))
      ])
    ];
    for (var index = 0; index < currentPath.length; ++index) {
      final path = currentPath.sublist(0, index + 1);
      var depth = (index == 0)
          ? _CovidEntityListItemDepth.root
          : _CovidEntityListItemDepth.stem;
      stemEntityList.add(Row(children: [
        Expanded(
            child: Container(
                color: UiColors.entityListStem,
                child: EntityListItem(path, depth, _onRegionPressed, pageModel,
                    timeseriesModel, numberFormatter)))
      ]));
    }

    // Add the children of the last parent entity.
    List<Widget> childEntityList = [];
    childEntityList.addAll(List<Widget>.from(childNames.map((name) =>
        EntityListItem([...currentPath, name], _CovidEntityListItemDepth.leaf,
            _onRegionPressed, pageModel, timeseriesModel, numberFormatter))));
    stemEntityList.add(Expanded(child: ListView(children: childEntityList)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stemEntityList,
    );
  }
}

class EntityListHeader extends StatelessWidget {
  final CovidEntitiesPageModel _pageModel;

  EntityListHeader(this._pageModel);

  @override
  build(BuildContext context) {
    var uiParameters = context.read<UiParameters>();
    return SizedBox(
        width: uiParameters.entityRowWidth,
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
              width: uiParameters.entityButtonWidth,
              child: TextButton(
                onPressed: () {},
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(UiColors.darkGreyText),
                    alignment: AlignmentDirectional(0, 0)),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Region',
                      style: uiParameters.entityButtonTextStyle,
                    )),
              ),
            ),
            SizedBox(
              width: uiParameters.entityMetricWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(_sortMetricName(),
                    style: uiParameters.entityMetricTextStyle),
              ),
            ),
          ],
        ));
  }

  String _sortMetricName() {
    var name = (_pageModel.sortMetric != UiConstants.noSortMetricName)
        ? _pageModel.sortMetric
        : UiConstants.defaultDisplayMetric;
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
    var uiParameters = context.read<UiParameters>();
    return Container(
        width: uiParameters.entityRowWidth,
        color: listEquals(_path, pageModel.chartPath())
            ? UiColors.entityListSelected
            : null,
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
              width: uiParameters.entityButtonWidth,
              child: TextButton(
                onPressed: onRegionPressed,
                onLongPress: onRegionLongPress,
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(UiColors.darkGreyText),
                    alignment: AlignmentDirectional(0, 0)),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _path.last,
                      style: uiParameters.entityButtonTextStyle,
                    )),
              ),
            ),
            SizedBox(
              width: uiParameters.entityMetricWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(_metricValueString(),
                    style: uiParameters.entityMetricTextStyle),
              ),
            ),
          ],
        ));
  }

  void onRegionLongPress() {
    _pageModel.clearComparisonPathList();
    onRegionPressed();
  }

  void _openParentPath() {
    _pageModel.setEntityPagePath(_path.sublist(0, _path.length - 1));
  }

  void _openPath() {
    _timeseriesModel.loadEntity(_path);
    _pageModel.setEntityPagePath(_path);
  }

  String _metricValueString() {
    String displayMetric = _pageModel.sortMetric;
    if (displayMetric == UiConstants.noSortMetricName) {
      displayMetric = UiConstants.defaultDisplayMetric;
    }
    var metricValue = _timeseriesModel.entitySortMetric(
        _path, displayMetric, _pageModel.per100k);
    return numberFormatter.format(metricValue);
  }
}
