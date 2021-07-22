import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEntity {
  final List<String> _path;
  List<int> _timestamps;
  Map<String, List<double>> _timeseries;
  Map<String, int> _sortKeys = {};
  Map<String, AdminEntity> _children = {};
  Map<String, AdminChildIndexData> _childIndex = {};
  AdminEntity _parent;
  bool _isStale = false;

  final _populationMetrics = [
    'Confirmed',
    'Confirmed 7-Day',
    'Deaths',
    'Deaths 7-Day'
  ];

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
    entity._isStale = false;
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
    _sortKeys = _extractDocSortKeys(docData);
    _childIndex = _extractDocChildIndex(docData);
    createRollingAverageDiff('Confirmed', 'Confirmed 7-Day', 7);
    createRollingAverageDiff('Deaths', 'Deaths 7-Day', 7);
    // TODO: Why do we need to filter outliers?  Check source data.
    filterOutliers('Population', 5);
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
      // TODO: Move timeseries into their own "Timeseries" field.
      if (key != "Date" && key != "Children" && key != "SortKeys") {
        timeseries[key] =
            List<double>.from(docData[key].map((x) => x.toDouble()));
      }
    }
    return timeseries;
  }

  static Map<String, int> _extractDocSortKeys(Map<String, dynamic> docData) {
    Map<String, dynamic> docMetrics = docData['SortKeys'];
    Map<String, int> sortKeys = {};
    for (var metric in docMetrics.keys) {
      sortKeys[metric] = docMetrics[metric];
    }
    return sortKeys;
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

  void filterOutliers(String seriesName, historyLength) {
    if (historyLength < 5) {
      return;
    }
    if (!_timeseries.containsKey(seriesName)) {
      return;
    }
    if (_timeseries[seriesName].length < historyLength) {
      return;
    }

    // TODO: Check for efficiency, improve if needed.
    // Maybe move this caclulation into database loading code.
    var unfiltered = _timeseries[seriesName];
    List<double> filtered = unfiltered.sublist(0, historyLength);
    for (int index = historyLength; index < unfiltered.length; ++index) {
      List<double> history = [];
      for (int historyIndex = max(0, index - historyLength);
          historyIndex < index;
          ++historyIndex) {
        history.add(filtered[historyIndex]);
      }
      var historyMin = history.reduce(min);
      var historyMax = history.reduce(max);
      var historyDelta = historyMax - historyMin;
      var historyAverage = history.reduce((a, b) => a + b) / history.length;
      var sample = unfiltered[index];
      var sampleDistance = (sample - historyAverage).abs();
      if (sampleDistance > 10 * historyDelta) {
        filtered.add(filtered[index - 1]);
      } else {
        filtered.add(sample);
      }
    }

    _timeseries[seriesName] = filtered;
    //_timeseries[seriesName] = List<double>.filled(unfiltered.length, 100000.0);
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
      var keyDifference = valueA - valueB;
      if (!sortUp) {
        keyDifference = -keyDifference;
      }
      if (keyDifference > 0.0) {
        return 1;
      } else if (keyDifference < 0.0) {
        return -1;
      } else {
        return 0;
      }
    });

    return names;
  }

  double normalizedMetric(
      int metricValue, String metricName, int population, bool per100k) {
    var value = 0.0;
    if (metricValue != null) {
      value = metricValue.toDouble();
    }
    if (population == 0) {
      value = 0.0;
      population = 1;
    }
    if (per100k) {
      if (_populationMetrics.contains(metricName)) {
        value = (100000.0 * value) / population;
      }
    }
    return value;
  }

  double sortMetricValue(String sortMetric, bool per100k) {
    return normalizedMetric(
        _sortKeys[sortMetric], sortMetric, _sortKeys['Population'], per100k);
  }

  double childSortMetricValue(
      String childName, String sortMetric, bool per100k) {
    if (!_childIndex.containsKey(childName)) {
      return 0.0;
    }
    if (!_childIndex[childName].sortKeys.containsKey(sortMetric)) {
      return 0.0;
    }
    return normalizedMetric(_childIndex[childName].sortKeys[sortMetric],
        sortMetric, _childIndex[childName].sortKeys['Population'], per100k);
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
