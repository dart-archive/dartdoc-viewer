// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library web.category;

import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/item.dart';
import 'app.dart';
import 'member.dart';
import 'dart:html';

/**
 * An HTML representation of a Category.
 *
 * Used as a placeholder for an CategoryItem object.
 */
 @CustomTag("dartdoc-category")
class CategoryElement extends DartdocElement {
  @published Category category;

  @observable String title;
  @observable String stylizedName;
  @observable var categoryContent;
  @observable List<Method> categoryMethods;
  @observable List<Variable> categoryVariables;
  @observable List categoryEverythingElse;

  @observable String accordionStyle;
  @observable String divClass;
  @observable String caretStyle;
  @observable String lineHeight;

  CategoryElement.created() : super.created() {
    registerObserver('viewer', viewer.changes.listen((changes) {
      if (changes.any((c) => c.name == #isInherited)) {
        categoryChanged();
      }
      if (changes.any((c) => c.name == #isDesktop)) {
        _isExpanded = viewer.isDesktop;
      }
    }));
    _isExpanded = viewer.isDesktop;
  }

  bool __isExpanded;
  bool get _isExpanded => __isExpanded;
  set _isExpanded(bool expanded) {
    __isExpanded = expanded;
    accordionStyle = expanded ? '' : 'collapsed';
    divClass = expanded ? 'collapse in' : 'collapse';
    caretStyle = expanded ? '' : 'caret';
    lineHeight = expanded ? 'auto' : '0px';
  }

  void categoryChanged() {
    title = category == null ? '' : category.name;
    stylizedName = category == null ? '' : category.name.replaceAll(' ', '-');
    categoryContent = category == null ? [] : category.content;

    categoryMethods = [];
    categoryVariables = [];
    categoryEverythingElse = [];
    for (var c in categoryContent) {
      if (c.isInherited && !viewer.isInherited) continue;

      List list;
      if (c is Method) {
        list = categoryMethods;
      } else if (c is Variable) {
        list = categoryVariables;
      } else {
        list = categoryEverythingElse;
      }
      list.add(c);
    }
  }

  hideShow(event, detail, AnchorElement target) {
    _isExpanded = !_isExpanded;
  }
}
