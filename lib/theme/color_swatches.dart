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

class ColorSwatches {
  static final blank = <int, Color>{
    900: HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.0).toColor(),
    800: HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.0).toColor(),
    700: HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.0).toColor(),
    600: HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.0).toColor(),
    500: HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.0).toColor(),
    400: HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.0).toColor(),
    300: HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.0).toColor(),
    200: HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.0).toColor(),
    100: HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.0).toColor(),
    50: HSLColor.fromAHSL(1.0, 0.0, 0.0, 0.0).toColor(),
  };
  static final coolGrey = <int, Color>{
    900: HSLColor.fromAHSL(1.0, 210.0, 0.24, 0.16).toColor(),
    800: HSLColor.fromAHSL(1.0, 209.0, 0.20, 0.25).toColor(),
    700: HSLColor.fromAHSL(1.0, 209.0, 0.18, 0.30).toColor(),
    600: HSLColor.fromAHSL(1.0, 209.0, 0.14, 0.37).toColor(),
    500: HSLColor.fromAHSL(1.0, 211.0, 0.12, 0.43).toColor(),
    400: HSLColor.fromAHSL(1.0, 211.0, 0.10, 0.53).toColor(),
    300: HSLColor.fromAHSL(1.0, 211.0, 0.13, 0.65).toColor(),
    200: HSLColor.fromAHSL(1.0, 210.0, 0.16, 0.82).toColor(),
    100: HSLColor.fromAHSL(1.0, 214.0, 0.15, 0.91).toColor(),
    50: HSLColor.fromAHSL(1.0, 216.0, 0.33, 0.97).toColor(),
  };
  static final lightBlueVivid = <int, Color>{
    900: HSLColor.fromAHSL(1.0, 204.0, 0.96, 0.27).toColor(),
    800: HSLColor.fromAHSL(1.0, 203.0, 0.87, 0.34).toColor(),
    700: HSLColor.fromAHSL(1.0, 202.0, 0.83, 0.41).toColor(),
    600: HSLColor.fromAHSL(1.0, 201.0, 0.79, 0.46).toColor(),
    500: HSLColor.fromAHSL(1.0, 199.0, 0.84, 0.55).toColor(),
    400: HSLColor.fromAHSL(1.0, 197.0, 0.92, 0.61).toColor(),
    300: HSLColor.fromAHSL(1.0, 196.0, 0.94, 0.67).toColor(),
    200: HSLColor.fromAHSL(1.0, 195.0, 0.97, 0.75).toColor(),
    100: HSLColor.fromAHSL(1.0, 195.0, 1.0, 0.85).toColor(),
    50: HSLColor.fromAHSL(1.0, 195.0, 1.0, 0.95).toColor(),
  };
  static final pinkVivid = <int, Color>{
    900: HSLColor.fromAHSL(1.0, 320.0, 1.0, 0.19).toColor(),
    800: HSLColor.fromAHSL(1.0, 322.0, 0.93, 0.27).toColor(),
    700: HSLColor.fromAHSL(1.0, 324.0, 0.93, 0.33).toColor(),
    600: HSLColor.fromAHSL(1.0, 326.0, 0.90, 0.39).toColor(),
    500: HSLColor.fromAHSL(1.0, 328.0, 0.85, 0.46).toColor(),
    400: HSLColor.fromAHSL(1.0, 330.0, 0.79, 0.56).toColor(),
    300: HSLColor.fromAHSL(1.0, 334.0, 0.86, 0.67).toColor(),
    200: HSLColor.fromAHSL(1.0, 336.0, 1.0, 0.77).toColor(),
    100: HSLColor.fromAHSL(1.0, 338.0, 1.0, 0.86).toColor(),
    50: HSLColor.fromAHSL(1.0, 341.0, 1.0, 0.95).toColor(),
  };
  static final redVivid = <int, Color>{
    900: HSLColor.fromAHSL(1.0, 348.0, 0.94, 0.20).toColor(),
    800: HSLColor.fromAHSL(1.0, 350.0, 0.94, 0.28).toColor(),
    700: HSLColor.fromAHSL(1.0, 352.0, 0.90, 0.35).toColor(),
    600: HSLColor.fromAHSL(1.0, 354.0, 0.85, 0.44).toColor(),
    500: HSLColor.fromAHSL(1.0, 356.0, 0.75, 0.53).toColor(),
    400: HSLColor.fromAHSL(1.0, 360.0, 0.83, 0.62).toColor(),
    300: HSLColor.fromAHSL(1.0, 360.0, 0.91, 0.69).toColor(),
    200: HSLColor.fromAHSL(1.0, 360.0, 1.0, 0.80).toColor(),
    100: HSLColor.fromAHSL(1.0, 360.0, 1.0, 0.87).toColor(),
    50: HSLColor.fromAHSL(1.0, 360.0, 1.0, 0.95).toColor(),
  };
  static final teal = <int, Color>{
    900: HSLColor.fromAHSL(1.0, 170.0, 0.97, 0.15).toColor(),
    800: HSLColor.fromAHSL(1.0, 168.0, 0.80, 0.23).toColor(),
    700: HSLColor.fromAHSL(1.0, 166.0, 0.72, 0.28).toColor(),
    600: HSLColor.fromAHSL(1.0, 164.0, 0.71, 0.34).toColor(),
    500: HSLColor.fromAHSL(1.0, 162.0, 0.63, 0.41).toColor(),
    400: HSLColor.fromAHSL(1.0, 160.0, 0.51, 0.49).toColor(),
    300: HSLColor.fromAHSL(1.0, 158.0, 0.58, 0.62).toColor(),
    200: HSLColor.fromAHSL(1.0, 156.0, 0.73, 0.74).toColor(),
    100: HSLColor.fromAHSL(1.0, 154.0, 0.75, 0.87).toColor(),
    50: HSLColor.fromAHSL(1.0, 152.0, 0.68, 0.96).toColor(),
  };
  static final yellowVivid = <int, Color>{
    900: HSLColor.fromAHSL(1.0, 15.0, 0.86, 0.30).toColor(),
    800: HSLColor.fromAHSL(1.0, 22.0, 0.82, 0.39).toColor(),
    700: HSLColor.fromAHSL(1.0, 29.0, 0.80, 0.44).toColor(),
    600: HSLColor.fromAHSL(1.0, 36.0, 0.77, 0.49).toColor(),
    500: HSLColor.fromAHSL(1.0, 42.0, 0.87, 0.55).toColor(),
    400: HSLColor.fromAHSL(1.0, 44.0, 0.92, 0.63).toColor(),
    300: HSLColor.fromAHSL(1.0, 48.0, 0.94, 0.68).toColor(),
    200: HSLColor.fromAHSL(1.0, 48.0, 0.95, 0.76).toColor(),
    100: HSLColor.fromAHSL(1.0, 48.0, 1.0, 0.88).toColor(),
    50: HSLColor.fromAHSL(1.0, 49.0, 1.0, 0.96).toColor(),
  };
}
