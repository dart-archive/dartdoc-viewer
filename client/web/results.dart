// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library results;

import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/search.dart';
import 'package:dartdoc_viewer/location.dart';
import 'package:polymer/polymer.dart';
import 'member.dart';
import 'dart:html';

/**
 * An HTML representation of a Search Result.
 */
@CustomTag("search-result")
class Result extends AnchorElement with Polymer, Observable {

  Result.created() : super.created();

  SearchResult _item;

  @published get item => _item;
  set item(newItem) {
    var oldItem = item;
    var oldObservables = [descriptiveName, descriptiveType, outerLibrary];
    _item = newItem;
    notifyPropertyChange(#item, oldItem, newItem);
    notifyPropertyChange(#descriptiveName, oldObservables.first,
        descriptiveName);
    notifyPropertyChange(#descriptiveType, oldObservables[1],
        descriptiveName);
    notifyPropertyChange(#outerLibrary, oldObservables.last, descriptiveName);
  }

  get applyAuthorStyles => true;

  @observable String get membertype => item == null ? 'none' : item.type;
  @observable String get qualifiedname => item == null ? 'none' : item.element;

  /// The name of this member.
  String get descriptiveName {
    if (qualifiedname == null) return '';
    // TODO(alanknight) : Look at unifying this with Location
    var name = qualifiedname.split('.');
    if (membertype == 'library') {
      if (name.first == 'dart') {
        return 'dart:${name.last}';
      }
    } else if (membertype == 'constructor') {
      // Non-named constructors have an empty string for the last element
      // of the qualified name, so we display the class name instead.
      if (name.last == '') return name[name.length - 2];
      return '${name[name.length - 2]}.${name.last}';
    }
    return name.last;
  }

  /// The type of this member.
  String get descriptiveType {
    if (item == null) return '';
    if (membertype == 'class' || membertype == 'library')
      return membertype;
    var ownerType = index[new DocsLocation(item.element).parentQualifiedName];
    if (ownerType == 'class')
      return '$membertype in ${new DocsLocation(item.element).parentName}';
    return membertype;
  }

  /// The library containing this member.
  String get outerLibrary {
    if (membertype == 'library') return '';
    var libraryName = new DocsLocation(qualifiedname).libraryName;
    return 'library $libraryName';
  }
}