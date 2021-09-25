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

import 'package:intl/intl.dart';

class MetricFormatter {
  static final integerFormatter = NumberFormat('#,###');
  static final doubleFormatter0 = NumberFormat('#0', 'en_US');
  static final doubleFormatter1 = NumberFormat('#0.0', 'en_US');
  static final doubleFormatter2 = NumberFormat('#0.00', 'en_US');
  static final doubleFormatter3 = NumberFormat('#0.000', 'en_US');
  static final doubleFormatter4 = NumberFormat('#0.0000', 'en_US');
  static final doubleFormatter5 = NumberFormat('#0.00000', 'en_US');
  static final doubleFormatter6 = NumberFormat('#0.000000', 'en_US');

  static NumberFormat doubleFormatter(double scale, {graphScale = true}) {
    if (scale == 0.0) {
      if (graphScale) {
        return doubleFormatter1;
      } else {
        return doubleFormatter0;
      }
    } else if (scale >= 1.0) {
      return doubleFormatter0;
    } else if (scale >= 0.1) {
      return doubleFormatter1;
    } else if (scale >= 0.01) {
      return doubleFormatter2;
    } else if (scale >= 0.001) {
      return doubleFormatter3;
    } else if (scale >= 0.0001) {
      return doubleFormatter4;
    } else if (scale >= 0.00001) {
      return doubleFormatter5;
    } else {
      return doubleFormatter6;
    }
  }
}
