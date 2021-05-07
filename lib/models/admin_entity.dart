import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEntity {
  final List<String> _path;
  final List<int> _timestamps;
  final Map<String, List<int>> _timeseries;
  List<String> _subEntityNames = [];
  Map<String, AdminEntity> _subEntities = {};
  bool _subEntitiesLoaded = false;
  AdminEntity _parent;

  AdminEntity.empty()
      : _path = <String>[],
        _timestamps = <int>[],
        _timeseries = <String, List<int>>{};

  AdminEntity._(this._path, this._timestamps, this._timeseries, this._parent);

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
    return AdminEntity._(path, timestamps, timeseries, parent);
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
      if (key != "Date") {
        timeseries[key] = List<int>.from(docData[key]);
      }
    }
    return timeseries;
  }

  List<String> get path => _path;

  List<int> get timestamps => _timestamps;

  List<int> seriesData(String key) {
    if (_timeseries.containsKey(key)) {
      return _timeseries[key];
    }
    return List<int>.filled(_timestamps.length, 0);
  }

  List<String> get subEntityNames => _subEntityNames;

  AdminEntity get parent => _parent;

  AdminEntity subEntity(String name) {
    if (_subEntities.containsKey(name)) {
      return _subEntities[name];
    }
    return this;
  }

  Future<void> loadSubEntities() async {
    if (!_subEntitiesLoaded) {
      final docPath = _docPath(_path);
      final collectionPath = docPath + '/entities';
      final query =
          await FirebaseFirestore.instance.collection(collectionPath).get();
      for (var doc in query.docs) {
        var subEntityPath = [..._path, doc.id];
        var timestamps = _extractDocTimestamps(doc.data());
        var timeseries = _extractDocTimeseries(doc.data());
        _subEntities[doc.id] =
            AdminEntity._(subEntityPath, timestamps, timeseries, this);
      }
      _subEntityNames = List<String>.from(_subEntities.keys);
      _subEntityNames.sort();
      _subEntitiesLoaded = true;
    }
  }
}
