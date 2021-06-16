import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class AdminEntity {
  final List<String> _path;
  List<int> _timestamps;
  Map<String, List<int>> _timeseries;
  Map<String, AdminEntity> _children = {};
  Map<String, AdminChildIndexData> _childIndex = {};
  AdminEntity _parent;
  bool _isStale = false;

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

  Future<void> refresh() async {
    if (!_isStale) {
      return null;
    }
    _isStale = false;

    final doc = await FirebaseFirestore.instance.doc(_docPath(path)).get();
    if (!doc.exists) {
      throw new Exception('Doc "${_docPath(path)}" does not exist.');
    }
    _timestamps = _extractDocTimestamps(doc.data());
    _timeseries = _extractDocTimeseries(doc.data());
    _childIndex = _extractDocChildIndex(doc.data());
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

  bool get isStale => _isStale;

  int _displayStart(int displayLength) {
    if (displayLength == 0) {
      return 0;
    }
    var displayStart = _timestamps.length - displayLength;
    if (displayStart > 0) {
      return displayStart;
    }
    return 0;
  }

  List<int> timestamps({seriesLength = 0}) {
    var displayStart = _displayStart(seriesLength);
    return _timestamps.sublist(displayStart);
  }

  List<int> seriesData(String key, {seriesLength = 0, per100k = false}) {
    var displayStart = _displayStart(seriesLength);

    if (_timeseries.containsKey(key)) {
      if (per100k && _timeseries.containsKey('Population')) {
        List<int> per100kSeries = [];
        for (int index = displayStart; index < _timestamps.length; ++index) {
          per100kSeries.add((100000 * _timeseries[key][index]) ~/
              _timeseries['Population'][index]);
        }
        return per100kSeries;
      } else {
        return _timeseries[key].sublist(displayStart);
      }
    }

    return List<int>.filled(_timestamps.length - displayStart, 0);
  }

  // TODO: Remove if/when entities contain their own sort metrics in addition
  // to their children's sort metrics.
  int seriesDataLast(String key) {
    if (_timeseries.containsKey(key)) {
      return _timeseries[key].last;
    }
    return 0;
  }

  bool get hasChildren => _childIndex.isNotEmpty;

  bool childrenContains(String name) {
    return _childIndex.containsKey(name);
  }

  List<String> childMetricNames() {
    if (_childIndex.isNotEmpty) {
      var names = List<String>.from(_childIndex.values.first._sortKeys.keys);
      names.remove('Population');
      return names;
    }
    return List<String>.empty();
  }

  List<String> childNames(
      {String sortBy = '', bool sortUp = true, bool per100k = false}) {
    var names = List<String>.from(_childIndex.keys);

    names.sort((String a, String b) {
      var valueA = childSortMetricValue(a, sortBy, per100k);
      var valueB = childSortMetricValue(b, sortBy, per100k);
      if (valueA == valueB) {
        return a.compareTo(b);
      }
      var keyCompare = valueA - valueB;
      if (!sortUp) {
        keyCompare = -keyCompare;
      }
      if (!per100k) {
        keyCompare *= 100000;
      }
      return keyCompare.toInt();
    });

    return names;
  }

  double childSortMetricValue(
      String childName, String sortMetric, bool per100k) {
    if (!_childIndex.containsKey(childName)) {
      return 0.0;
    }
    if (!_childIndex[childName].sortKeys.containsKey(sortMetric)) {
      return 0.0;
    }
    var value = _childIndex[childName].sortKeys[sortMetric].toDouble();
    var population = _childIndex[childName].sortKeys['Population'].toDouble();
    if (population == 0) {
      value = 0;
      population = 1;
    }
    if (per100k) {
      value = (100000 * value) / population;
    }
    return value;
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

  void halveTreeHistory() {
    var prunedHistorySize = _timestamps.length ~/ 2;
    _timestamps = _timestamps.sublist(0, prunedHistorySize);
    for (var metricName in _timeseries.keys) {
      _timeseries[metricName] =
          _timeseries[metricName].sublist(0, prunedHistorySize);
    }

    for (var node in _children.values) {
      node.halveTreeHistory();
    }
  }

  void markTreeStale() {
    _isStale = true;
    for (var node in _children.values) {
      node.markTreeStale();
    }
  }
}

class AdminChildIndexData {
  final Map<String, int> _sortKeys;
  final bool _hasChildren;
  AdminChildIndexData(this._sortKeys, this._hasChildren);

  Map<String, int> get sortKeys => _sortKeys;

  bool get hasChildren => _hasChildren;
}
