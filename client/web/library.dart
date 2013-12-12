// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library web.library;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'member.dart';

@CustomTag("dartdoc-library")
class LibraryElement extends MemberElement {
  LibraryElement.created() : super.created();

  wrongClass(newItem) => newItem is! Library;

  get defaultItem => _defaultItem;
  static final _defaultItem =
      new Library.forPlaceholder({ 'name': 'loading', 'preview': 'loading' });
}
