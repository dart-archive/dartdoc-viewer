// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * Library to hold all the data needed in the app.
 */
library data;

import 'package:dartdoc_viewer/item.dart';
import 'dart:collection';

// Pages generated from the YAML file. Keys are the title of the pages.
final Map<String, Item> pageIndex = new _PageIndex();

// Determines if the input files are in YAML format or JSON format.
bool isYaml = false;

/// The list of libraries whose library name disagrees with how we want to
/// present them. For example 'dart:html' vs 'dart-dom-html'. So if we see
/// a name with a colon, we also look for it by converting the colon to a
/// hyphen,
/// which may be an existing name, and also checking it against this list,
/// in which case it may be a valid name if insert 'dom-'.
const domLibraries = const ["dart-html", "dart-svg", "dart-web_audio",
    "dart-web_gl", "dart-web_sql", "dart-indexed_db"];

/// A lookup for the pages we have read from files. It does a normal lookup, but
/// can handle library names either with hyphens, colons, or dom in their name.
/// e.g. dart:html, dart-collections, dart-dom-web_gl.
class _PageIndex extends MapBase<String, Item> {
  final _index = new HashMap<String, Item>();
  Item remove(String key) => _index.remove(key);
  operator [](String key) {
    if (_index.containsKey(key)) return _index[key];
    if (!key.startsWith("dart:")) return null;
    var withHyphen = key.replaceFirst("dart:", "dart-");
    if (domLibraries.contains(withHyphen)) {
      return _index[withHyphen.replaceFirst("-", "-dom-")];
    }
    return _index[withHyphen];
  }
  operator []=(String key, Item value) => _index[key] = value;
  void clear() => _index.clear();
  Iterable get keys => _index.keys;
}
