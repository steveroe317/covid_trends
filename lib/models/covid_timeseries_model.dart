import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CovidTimeseriesModel with ChangeNotifier {
  bool _initialized = false;
  List<int> worldConfirmed7Days;
  List<int> worldTimestamps;
  var worldData = Map<String, List<int>>();

  void initialize() async {
    if (!_initialized) {
      _initialized = true;
      final doc = await FirebaseFirestore.instance
          .collection('time-series')
          .doc('World')
          .collection('entities')
          .doc('US')
          .collection('entities')
          .doc('WA')
          .collection('entities')
          .doc('King')
          .get();
      if (!doc.exists) {
        throw new Exception('Oops!  Doc doesn;t exist :(');
      }
      var worldMap = doc.data();
      worldTimestamps =
          List<Timestamp>.from(worldMap['Date']).map((x) => x.seconds).toList();
      for (var key in worldMap.keys) {
        if (key != "Date") {
          worldData[key] = List<int>.from(worldMap[key]);
        }
      }
      worldConfirmed7Days = List<int>.from(worldMap['Confirmed 7-Day']);
      notifyListeners();
    }
  }

  bool get initialized => _initialized;

  List<int> get timestamps => worldTimestamps;

  List<int> seriesData(String key) {
    if (worldData.containsKey(key)) {
      return worldData[key];
    }
    return List<int>.filled(worldTimestamps.length, 0);
  }
}
