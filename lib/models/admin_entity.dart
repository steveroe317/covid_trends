import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEntity {
  final List<String> _path;
  final List<int> _timestamps;
  final Map<String, List<int>> _timeseries;
  Map<String, AdminEntity> _subEntities = {};
  Map<String, AdminSubEntityIndexData> _subEntityIndex = {};
  AdminEntity _parent;

  AdminEntity.empty()
      : _path = <String>[],
        _timestamps = <int>[],
        _timeseries = <String, List<int>>{};

  AdminEntity._(this._path, this._timestamps, this._timeseries,
      this._subEntityIndex, this._parent);

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
    var subEntityIndex = _extractDocSubEntityIndex(doc.data());
    var entity =
        AdminEntity._(path, timestamps, timeseries, subEntityIndex, parent);
    if (parent != null) {
      parent._subEntities[path.last] = entity;
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

  static Map<String, AdminSubEntityIndexData> _extractDocSubEntityIndex(
      Map<String, dynamic> docData) {
    Map<String, AdminSubEntityIndexData> subEntityIndex = {};
    Map<String, dynamic> docSubEntities = docData['Children'];
    for (var child in docSubEntities.keys) {
      Map<String, int> sortKeys = {};
      Map<String, dynamic> childData = docData['Children'][child];
      Map<String, dynamic> docSubEntityMetrics = childData['SortKeys'];
      for (var metric in docSubEntityMetrics.keys) {
        sortKeys[metric] = childData[metric];
      }
      bool hasChildren = childData['HasChildren'];
      subEntityIndex[child] = AdminSubEntityIndexData(sortKeys, hasChildren);
    }
    return subEntityIndex;
  }

  List<String> get path => _path;

  List<int> get timestamps => _timestamps;

  List<int> seriesData(String key) {
    if (_timeseries.containsKey(key)) {
      return _timeseries[key];
    }
    return List<int>.filled(_timestamps.length, 0);
  }

  bool get hasSubEntities => _subEntityIndex.isNotEmpty;

  bool subEntitiesContains(String name) {
    return _subEntityIndex.containsKey(name);
  }

  List<String> subEntityNames() {
    var names = List<String>.from(_subEntityIndex.keys);
    names.sort();
    return names;
  }

  bool subEntityHasChildren(String name) {
    if (_subEntityIndex.containsKey(name)) {
      return _subEntityIndex[name].hasChildren;
    }
    return false;
  }

  AdminEntity get parent => _parent;

  AdminEntity subEntity(String name) {
    if (_subEntities.containsKey(name)) {
      return _subEntities[name];
    }
    return null;
  }
}

class AdminSubEntityIndexData {
  final Map<String, int> _sortKeys;
  final bool _hasChildren;
  AdminSubEntityIndexData(this._sortKeys, this._hasChildren);

  Map<String, int> get sortKeys => _sortKeys;

  bool get hasChildren => _hasChildren;
}
