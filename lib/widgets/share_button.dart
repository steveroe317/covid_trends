import 'package:flutter/material.dart';

import '../models/widget_image_sharer.dart';

IconButton buildShareButton(BuildContext context, Key chartGroupKey) {
  return IconButton(
      onPressed: () {
        //print('share pressed');
        WidgetImageSharer.share(chartGroupKey);
      },
      icon: const Icon(Icons.ios_share));
}
