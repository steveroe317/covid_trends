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
// limitations under the License.

import 'package:flutter/material.dart';

enum GraphLineFadeTypes {
  toTrueBlack,
  toColoredBlack,
  toTrueWhite,
  toColoredWhite,
  toGrey,
}

enum GraphLineHighlightTypes {
  pop,
  toTrueBlack,
  toColoredBlack,
}

/// Colors and highlight/fade operations for graphs.
class GraphColors {
  // Colors for single region graphs.
  static final confirmed = Colors.black;
  static final deaths = Colors.red;
  static late final singleDefault = basicColors[0];

  // Colors for comparison graphs from the quantitative palette example in
  // https://chartio.com/learn/charts/how-to-choose-colors-data-visualization/
  // Removed Color(0xFFF6CA58) because it did not work well with programmatic
  // highlighting.
  static final basicColors = <Color>[
    Color(0xFF0483A6),
    //Color(0xFFF6CA58),
    Color(0xFF704C7D),
    Color(0xFF9BDA60),
    Color(0xFFCB482B),
    Color(0xFFFFA250),
    Color(0xFF8BDDD0),
  ];

  static Color fade(
      Color color, GraphLineFadeTypes fadeType, double fadeFactor) {
    switch (fadeType) {
      case GraphLineFadeTypes.toTrueBlack:
        return fadetoTrueBlack(color, fadeFactor);
      case GraphLineFadeTypes.toColoredBlack:
        return fadetoColoredBlack(color, fadeFactor);
      case GraphLineFadeTypes.toTrueWhite:
        return fadetoTrueWhite(color, fadeFactor);
      case GraphLineFadeTypes.toColoredWhite:
        return fadetoColoredWhite(color, fadeFactor);
      case GraphLineFadeTypes.toGrey:
        return fadetoGrey(color, fadeFactor);
    }
  }

  static Color highlight(Color color, GraphLineHighlightTypes highlightType,
      double highlightFactor) {
    switch (highlightType) {
      case GraphLineHighlightTypes.pop:
        return fadetoPop(color, highlightFactor);
      case GraphLineHighlightTypes.toTrueBlack:
        return fadetoTrueBlack(color, highlightFactor);
      case GraphLineHighlightTypes.toColoredBlack:
        return fadetoColoredBlack(color, highlightFactor);
    }
  }

  static Color fadetoTrueBlack(Color color, double fade) {
    var hsl = HSLColor.fromColor(color);
    var lightness = fadeToZero(hsl.lightness, fade);
    var saturation = fadeToZero(hsl.saturation, fade);
    return HSLColor.fromAHSL(hsl.alpha, hsl.hue, saturation, lightness)
        .toColor();
  }

  static Color fadetoColoredBlack(Color color, double fade) {
    var hsl = HSLColor.fromColor(color);
    var lightness = fadeToZero(hsl.lightness, fade);
    return HSLColor.fromAHSL(hsl.alpha, hsl.hue, hsl.saturation, lightness)
        .toColor();
  }

  static Color fadetoColoredWhite(Color color, double fade) {
    var hsl = HSLColor.fromColor(color);
    var lightness = fadeToOne(hsl.lightness, fade);
    return HSLColor.fromAHSL(hsl.alpha, hsl.hue, hsl.saturation, lightness)
        .toColor();
  }

  static Color fadetoTrueWhite(Color color, double fade) {
    var hsl = HSLColor.fromColor(color);
    var lightness = fadeToOne(hsl.lightness, fade);
    var saturation = fadeToZero(hsl.saturation, fade);
    return HSLColor.fromAHSL(hsl.alpha, hsl.hue, saturation, lightness)
        .toColor();
  }

  static Color fadetoGrey(Color color, double fade) {
    var hsl = HSLColor.fromColor(color);
    var lightness = fadeToCenter(hsl.lightness, fade);
    var saturation = fadeToZero(hsl.saturation, fade);
    return HSLColor.fromAHSL(hsl.alpha, hsl.hue, saturation, lightness)
        .toColor();
  }

  static Color fadetoPop(Color color, double fade) {
    var hsl = HSLColor.fromColor(color);
    var lightness = fadeToCenter(hsl.lightness, fade);
    var saturation = fadeToOne(hsl.saturation, fade);
    return HSLColor.fromAHSL(hsl.alpha, hsl.hue, saturation, lightness)
        .toColor();
  }

  static double fadeToZero(double value, double fade) {
    if (fade >= 1.0) {
      return 0.0;
    }
    if (fade <= 0.0) {
      return value;
    }
    return (1.0 - fade) * value;
  }

  static double fadeToOne(double value, double fade) {
    if (fade >= 1.0) {
      return 1.0;
    }
    if (fade <= 0.0) {
      return value;
    }
    return value + (1.0 - value) * fade;
  }

  static double fadeToCenter(double value, double fade) {
    if (fade >= 1.0) {
      return 0.5;
    }
    if (fade <= 0.0) {
      return value;
    }
    return value + (0.5 - value) * fade;
  }
}
