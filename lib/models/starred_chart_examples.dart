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
];
