import 'package:flutter/material.dart';

class InitializationErrorPage extends StatelessWidget {
  @override
  build(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Center(
          child: Text('Error loading Covid Trends',
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              textScaleFactor: 2.0,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
    );
  }
}
