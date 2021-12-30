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

import '../theme/palette_colors.dart';

class UiColors {
  static final darkGreyText = PaletteColors.coolGrey.shade900;
  static final disabledText = PaletteColors.coolGrey.shade400;
  static final entityListLeaf = PaletteColors.coolGrey.shade50;
  static final entityListSelected = PaletteColors.lightBlueVivid.shade200;
  static final entityListStem = PaletteColors.coolGrey.shade100;
  static final entityListHeader = PaletteColors.coolGrey.shade200;
  static final chartBackground = Colors.grey[50];
}
