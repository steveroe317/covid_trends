import 'package:flutter/material.dart';

class InitializationErrorPage extends StatelessWidget {
  final String message;
  final void Function() retry;

  InitializationErrorPage(this.retry, this.message);

  @override
  build(BuildContext context) {
    return MaterialApp(
        color: Colors.grey,
        home: Scaffold(
            body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Sorry, there was an error $message',
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                textScaleFactor: 2.0,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: retry,
              child: Text('Please try again',
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.center,
                  textScaleFactor: 2.0,
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ]),
        )));
  }
}
