import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    return Container(
        color: Colors.grey,
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Loading Covid Trends',
                  textDirection: TextDirection.ltr, textScaleFactor: 2.0)),
          Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                  backgroundColor: Colors.blue.shade200)),
        ])));
  }
}
