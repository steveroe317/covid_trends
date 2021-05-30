import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/covid_entities_page_model.dart';
import '../models/covid_timeseries_model.dart';
import 'simple_chart_page.dart';

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
      ),
      body: CovidEntityList(),
    );
  }
}

class CovidEntityList extends StatelessWidget {
  @override
  build(BuildContext context) {
    var timeseriesModel = Provider.of<CovidTimeseriesModel>(context);
    var entityPathModel = Provider.of<CovidEntitiesPageModel>(context);
    final childNames = timeseriesModel.entityChildNames(entityPathModel.path(),
        sortBy: 'Confirmed 7-Day', sortUp: false);
    final currentPath = entityPathModel.path();

    List<Widget> entityList = [];

    for (var index = 0; index < currentPath.length; ++index) {
      final path = currentPath.sublist(0, index + 1);
      var depth = (index == 0)
          ? _CovidEntityListItemDepth.root
          : _CovidEntityListItemDepth.stem;
      entityList
          .add(EntityListItem(path, depth, entityPathModel, timeseriesModel));
    }

    if (currentPath.length > 0) {
      entityList.add(Divider());
    }

    entityList.addAll(List<Widget>.from(childNames.map((name) => EntityListItem(
        [...currentPath, name],
        _CovidEntityListItemDepth.leaf,
        entityPathModel,
        timeseriesModel))));

    return ListView(children: entityList);
  }
}

enum _CovidEntityListItemDepth { root, stem, leaf }

class EntityListItem extends StatelessWidget {
  final List<String> _path;
  final _CovidEntityListItemDepth _depth;
  final CovidTimeseriesModel _timeseriesModel;
  final CovidEntitiesPageModel _entityPathModel;

  EntityListItem(
      this._path, this._depth, this._entityPathModel, this._timeseriesModel);

  @override
  build(BuildContext context) {
    return Row(
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
        TextButton(
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
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.black)),
            child:
                Text(_path.last, style: Theme.of(context).textTheme.headline6)),
      ],
    );
  }

  void _openParentPath() {
    _entityPathModel.setPath(_path.sublist(0, _path.length - 1));
  }

  void _openPath() {
    _timeseriesModel.loadEntity(_path);
    _entityPathModel.setPath(_path);
  }
}
