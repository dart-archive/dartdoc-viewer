// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library homepage;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'dart:html';
import 'member.dart';

@CustomTag("dartdoc-homepage")
class HomeElement extends MemberElement {
  HomeElement.created() : super.created() {
    new PathObserver(this, "viewer.libraries").bindSync(
        (_) => addChildren);
  }

  get defaultItem => null;
  get observables => concat(super.observables,
      const [#libraries, #addChildren]);
  wrongClass(newItem) => newItem is! Home;

  get item => super.item;
  set item(newItem) => super.item = newItem;

  @observable get libraries => item == null ? [] : viewer.libraries;

  enteredView() {
    super.enteredView();
    addChildren;
    }

  /// Dynamically generate elements for all of our libraries, for performance
  /// reasons.
  @observable get addChildren {
    // TODO(alanknight): Move this and other occurences of addChildren back
    // into templates if they get acceptable performance.
    if (shadowRoot == null) return;
    var elements = [];
    for (var library in libraries) {
      var newItem = document.createElement('dartdoc-item');
      newItem.item = library;
      newItem.classes.add("panel");
      elements.add(newItem);
    }
    var root = shadowRoot.querySelector("#librariesGoHere");
    if (root == null) return;
    root.children.clear();
    root.children.addAll(elements);
  }
}