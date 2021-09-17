//import 'dart:developer' as developer;
import 'dart:io';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class WidgetImageSharer {
  static void share(widgetKey) async {
    try {
      final RenderRepaintBoundary boundary =
          widgetKey.currentContext.findRenderObject();
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      var buffer = byteData?.buffer;
      if (buffer != null) {
        final pngBytes = buffer.asUint8List();
        final tmpDir = '${(await getTemporaryDirectory()).path}';
        final filePath = '$tmpDir/${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(pngBytes);
        Share.shareFiles([filePath],
            text: 'Covid Flows',
            sharePositionOrigin: Rect.fromLTWH(0, 0, 200, 200));
      }
    } catch (e) {
      print(e);
    }
  }
}
