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

import 'starred_model.dart';
import '../theme/graph_colors.dart';

var starredChartExamples = <StarredModel>[
  StarredModel(
    'California Florida',
    true,
    true,
    0,
    ['World', 'United States', 'California'],
    ['World', 'United States', 'California'],
    [
      ['World', 'United States', 'California'],
      ['World', 'United States', 'Florida'],
    ],
    [0, 1],
    [false, false],
    GraphLineFadeTypes.toColoredWhite,
    0.25,
    0x40,
    GraphLineHighlightTypes.pop,
    0.50,
  ),
  StarredModel(
    'Israel 240',
    false,
    true,
    240,
    ['World', 'Israel'],
    ['World', 'Israel'],
    [
      ['World', 'Israel'],
    ],
    [0],
    [false],
    GraphLineFadeTypes.toColoredWhite,
    0.25,
    0x40,
    GraphLineHighlightTypes.pop,
    0.50,
  ),
  StarredModel(
    'King 60',
    true,
    true,
    60,
    ['World', 'United States'],
    ['World', 'United States'],
    [
      ['World', 'United States'],
      ['World', 'United States', 'Washington'],
      ['World', 'United States', 'Washington', 'King'],
      ['World', 'Canada'],
    ],
    [0, 1, 2, 3],
    [false, false, true, false],
    GraphLineFadeTypes.toColoredWhite,
    0.25,
    0x40,
    GraphLineHighlightTypes.toColoredBlack,
    0.50,
  ),
  StarredModel(
    'Oz NZed',
    true,
    true,
    0,
    ['World', 'Australia'],
    ['World', 'Australia'],
    [
      ['World', 'Australia'],
      ['World', 'New Zealand'],
    ],
    [0, 1],
    [false, false],
    GraphLineFadeTypes.toColoredWhite,
    0.25,
    0x40,
    GraphLineHighlightTypes.pop,
    0.50,
  ),
  StarredModel(
    'Scandinavia',
    true,
    true,
    0,
    ['World', 'Finland'],
    ['World', 'Finland'],
    [
      ['World', 'Finland'],
      ['World', 'Denmark'],
      ['World', 'Norway'],
      ['World', 'Sweden'],
    ],
    [0, 1, 2, 3],
    [false, false, false, false],
    GraphLineFadeTypes.toColoredWhite,
    0.25,
    0x40,
    GraphLineHighlightTypes.pop,
    0.50,
  ),
  StarredModel(
    'UK 240',
    false,
    true,
    240,
    ['World', 'United Kingdom'],
    ['World', 'United Kingdom'],
    [
      ['World', 'United Kingdom'],
    ],
    [0],
    [false],
    GraphLineFadeTypes.toColoredWhite,
    0.25,
    0x40,
    GraphLineHighlightTypes.pop,
    0.50,
  ),
];
