import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEntity {
  final List<String> _path;
  List<int> _timestamps;
  Map<String, List<double>> _timeseries;
  Map<String, AdminEntity> _children = {};
  Map<String, AdminChildIndexData> _childIndex = {};
  AdminEntity _parent;
  bool _isStale = false;

  AdminEntity.empty()
      : _path = <String>[],
        _timestamps = <int>[],
        _timeseries = <String, List<double>>{};

  AdminEntity._(this._path, this._parent);

  static Future<AdminEntity> create(
      List<String> path, AdminEntity parent) async {
    if (path.isEmpty) {
      return AdminEntity.empty();
    }
    final doc = await FirebaseFirestore.instance.doc(_docPath(path)).get();
    if (!doc.exists) {
      throw new Exception('Doc "${_docPath(path)}" does not exist.');
    }
    var entity = AdminEntity._(path, parent);
    entity.importDocData(doc.data());
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
    importDocData(doc.data());
  }

  void importDocData(Map<String, dynamic> docData) {
    _timestamps = _extractDocTimestamps(docData);
    _timeseries = _extractDocTimeseries(docData);
    _childIndex = _extractDocChildIndex(docData);
    createRollingAverageDiff('Confirmed', 'Confirmed 7-Day', 7);
    createRollingAverageDiff('Deaths', 'Deaths 7-Day', 7);
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

  static Map<String, List<double>> _extractDocTimeseries(
      Map<String, dynamic> docData) {
    var timeseries = Map<String, List<double>>();
    for (var key in docData.keys) {
      if (key != "Date" && key != "Children") {
        timeseries[key] =
            List<double>.from(docData[key].map((x) => x.toDouble()));
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

  void createRollingAverageDiff(String source, String target, windowSize) {
    if (!_timeseries.containsKey(source)) {
      return;
    }

    // Calculate daily diffs.
    List<double> daily = [];
    var prevValue = 0.0;
    for (var value in _timeseries[source]) {
      if (value >= 0 && prevValue >= 0 && value >= prevValue) {
        daily.add(value - prevValue);
      } else {
        daily.add(0.0);
      }
      prevValue = value;
    }

    // Calculate rolling N day average.
    List<double> rollingAverage = [];
    double rollingSum = 0.0;
    var rollingSamples = Queue<double>();
    for (var sample in daily) {
      rollingSum += sample;
      rollingSamples.addLast(sample);
      if (rollingSamples.length > windowSize) {
        rollingSum -= rollingSamples.removeFirst();
      }
      rollingAverage.add(rollingSum / rollingSamples.length);
    }

    _timeseries[target] = rollingAverage;
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

  List<double> seriesData(String key, {seriesLength = 0, per100k = false}) {
    var displayStart = _displayStart(seriesLength);

    if (_timeseries.containsKey(key)) {
      if (per100k && _timeseries.containsKey('Population')) {
        List<double> per100kSeries = [];
        for (int index = displayStart; index < _timestamps.length; ++index) {
          per100kSeries.add((100000 * _timeseries[key][index]) /
              _timeseries['Population'][index]);
        }
        return per100kSeries;
      } else {
        return List<double>.from(_timeseries[key].sublist(displayStart));
      }
    }

    return List<double>.filled(_timestamps.length - displayStart, 0);
  }

  // TODO: Remove if/when entities contain their own sort metrics in addition
  // to their children's sort metrics.
  double seriesDataLast(String key) {
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
