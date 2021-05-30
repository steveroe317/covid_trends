import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEntity {
  final List<String> _path;
  final List<int> _timestamps;
  final Map<String, List<int>> _timeseries;
  Map<String, AdminEntity> _children = {};
  Map<String, AdminChildIndexData> _childIndex = {};
  AdminEntity _parent;

  AdminEntity.empty()
      : _path = <String>[],
        _timestamps = <int>[],
        _timeseries = <String, List<int>>{};

  AdminEntity._(this._path, this._timestamps, this._timeseries,
      this._childIndex, this._parent);

  static Future<AdminEntity> create(
      List<String> path, AdminEntity parent) async {
    if (path.isEmpty) {
      return AdminEntity.empty();
    }
    final doc = await FirebaseFirestore.instance.doc(_docPath(path)).get();
    if (!doc.exists) {
      throw new Exception('Doc "${_docPath(path)}" does not exist.');
    }
    var timestamps = _extractDocTimestamps(doc.data());
    var timeseries = _extractDocTimeseries(doc.data());
    var childIndex = _extractDocChildIndex(doc.data());
    var entity =
        AdminEntity._(path, timestamps, timeseries, childIndex, parent);
    if (parent != null) {
      parent._children[path.last] = entity;
    }
    return entity;
  }

  static String _docPath(path) {
    var pathBuffer = StringBuffer();
    for (var index = 0; index < path.length; ++index) {
      pathBuffer.write((index == 0) ? 'time-series/' : '/entities/');
      pathBuffer.write(path[index]);
    }
    var docPath = pathBuffer.toString();
    return docPath;
  }

  static List<int> _extractDocTimestamps(Map<String, dynamic> docData) {
    var timestamps =
        List<Timestamp>.from(docData['Date']).map((x) => x.seconds).toList();
    return timestamps;
  }

  static Map<String, List<int>> _extractDocTimeseries(
      Map<String, dynamic> docData) {
    var timeseries = Map<String, List<int>>();
    for (var key in docData.keys) {
      if (key != "Date" && key != "Children") {
        timeseries[key] = List<int>.from(docData[key]);
      }
    }
    return timeseries;
  }

  static Map<String, AdminChildIndexData> _extractDocChildIndex(
      Map<String, dynamic> docData) {
    Map<String, AdminChildIndexData> childIndex = {};
    Map<String, dynamic> docChildren = docData['Children'];
    for (var child in docChildren.keys) {
      Map<String, int> sortKeys = {};
      Map<String, dynamic> childData = docData['Children'][child];
      Map<String, dynamic> docChildMetrics = childData['SortKeys'];
      for (var metric in docChildMetrics.keys) {
        sortKeys[metric] = docChildMetrics[metric];
      }
      bool hasChildren = childData['HasChildren'];
      childIndex[child] = AdminChildIndexData(sortKeys, hasChildren);
    }
    return childIndex;
  }

  List<String> get path => _path;

  List<int> get timestamps => _timestamps;

  List<int> seriesData(String key) {
    if (_timeseries.containsKey(key)) {
      return _timeseries[key];
    }
    return List<int>.filled(_timestamps.length, 0);
  }

  bool get hasChildren => _childIndex.isNotEmpty;

  bool childrenContains(String name) {
    return _childIndex.containsKey(name);
  }

  List<String> childNames({String sortBy = '', bool sortUp = true}) {
    var names = List<String>.from(_childIndex.keys);

    names.sort((String a, String b) {
      if (_childIndex[a].sortKeys.containsKey(sortBy) &&
          _childIndex[b].sortKeys.containsKey(sortBy) &&
          _childIndex[a].sortKeys[sortBy] != _childIndex[b].sortKeys[sortBy]) {
        var keyCompare =
            _childIndex[a].sortKeys[sortBy] - _childIndex[b].sortKeys[sortBy];
        if (!sortUp) {
          keyCompare = -keyCompare;
        }
        return keyCompare;
      }
      return a.compareTo(b);
    });

    return names;
  }

  bool childHasChildren(String name) {
    if (_childIndex.containsKey(name)) {
      return _childIndex[name].hasChildren;
    }
    return false;
  }

  AdminEntity get parent => _parent;

  AdminEntity child(String name) {
    if (_children.containsKey(name)) {
      return _children[name];
    }
    return null;
  }
}

class AdminChildIndexData {
  final Map<String, int> _sortKeys;
  final bool _hasChildren;
  AdminChildIndexData(this._sortKeys, this._hasChildren);

  Map<String, int> get sortKeys => _sortKeys;

  bool get hasChildren => _hasChildren;
}
