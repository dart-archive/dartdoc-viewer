// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library library_panel;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart' as app;
import 'member.dart';
import 'dart:html';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-library-panel")
class LibraryPanel extends DartdocElement {
  LibraryPanel.created() : super.created() {
    new PathObserver(this, "viewer.libraries").bindSync(
    (_) {
      notifyPropertyChange(#createEntries, null, true);
    });
  }

  enteredView() {
    super.enteredView();
    createEntries();
  }

  linkHref(library) => library == null ? '' : library.linkHref;

  @observable void createEntries() {
    var mainElement = shadowRoot.querySelector("#library-panel");
    if (mainElement == null) return;
    mainElement.children.clear();
    var breadcrumbs = viewer.breadcrumbs;
    for (var library in viewer.libraries) {
      var isFirst =
          library.decoratedName == breadcrumbs.first.decoratedName;
      var element =
          isFirst ? newElement(library, true) : newElement(library, false);
      mainElement.append(element);
    }
  }

  newElement(library, bool isActive) {
    var html = '<a href="#${linkHref(library)}" class="list-group-item'
        '${isActive ? ' active' : ''}">'
        '${library.decoratedName}</a>';
    return new Element.html(html, treeSanitizer: sanitizer);
  }
}