// Copyright 2021 Stephen Roe
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.import 'dart:collection';

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
