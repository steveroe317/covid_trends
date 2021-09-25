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

import 'package:flutter/material.dart';

import 'color_swatches.dart';

class PaletteColors {
  static final coolGrey =
      MaterialColor(ColorSwatches.coolGrey[500]!.value, ColorSwatches.coolGrey);
  static final lightBlueVivid = MaterialColor(
      ColorSwatches.lightBlueVivid[700]!.value, ColorSwatches.lightBlueVivid);
  static final pinkVivid = MaterialColor(
      ColorSwatches.pinkVivid[500]!.value, ColorSwatches.pinkVivid);
  static final redVivid =
      MaterialColor(ColorSwatches.redVivid[500]!.value, ColorSwatches.redVivid);
  static final teal =
      MaterialColor(ColorSwatches.teal[500]!.value, ColorSwatches.teal);
  static final yellowVivid = MaterialColor(
      ColorSwatches.yellowVivid[500]!.value, ColorSwatches.yellowVivid);
}
