import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final subEntityNames = timeseriesModel.subEntityNames();
    final currentPath = timeseriesModel.path;

    var entityList = List<Widget>.from(subEntityNames.map((name) =>
        EntityListItem([...currentPath, name], _CovidEntityListItemDepth.leaf,
            timeseriesModel)));

    if (currentPath.length > 0) {
      entityList.insert(0, Divider());
    }

    for (var index = currentPath.length - 1; index >= 0; --index) {
      final path = currentPath.sublist(0, index + 1);
      var depth = (index == 0)
          ? _CovidEntityListItemDepth.root
          : _CovidEntityListItemDepth.stem;
      entityList.insert(0, EntityListItem(path, depth, timeseriesModel));
    }

    return ListView(children: entityList);
  }
}

enum _CovidEntityListItemDepth { root, stem, leaf }

class EntityListItem extends StatelessWidget {
  final List<String> _path;
  final _CovidEntityListItemDepth _depth;
  final CovidTimeseriesModel _timeseriesModel;

  EntityListItem(this._path, this._depth, this._timeseriesModel);

  @override
  build(BuildContext context) {
    return Row(
      children: [
        Opacity(
          opacity: (_depth != _CovidEntityListItemDepth.root &&
                  _timeseriesModel.entityHasSubEntities(_path))
              ? 1.0
              : 0.0,
          child: IconButton(
              icon: Icon(_depth == _CovidEntityListItemDepth.leaf
                  ? Icons.expand_more
                  : Icons.expand_less),
              onPressed: (_depth == _CovidEntityListItemDepth.stem)
                  ? _openParentPath
                  : (_depth == _CovidEntityListItemDepth.leaf &&
                          _timeseriesModel.entityHasSubEntities(_path))
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
    var parentPath = _path.sublist(0, _path.length - 1);
    print(parentPath);
    _timeseriesModel.openPath(_path.sublist(0, _path.length - 1));
    print(_path);
  }

  void _openPath() {
    print(_path);
    _timeseriesModel.openPath(_path);
    print(_path);
  }
}
