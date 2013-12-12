// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library web.class_;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';
import 'dart:html';

@CustomTag("dartdoc-class")
class ClassElement extends MemberElement {
  static const MAX_SUBCLASSES_TO_SHOW = 3;

  ClassElement.created() : super.created();

  get defaultItem => _defaultItem;
  static final _defaultItem = new Class.forPlaceholder('loading.loading',
      'loading');

  bool wrongClass(newItem) => newItem is! Class;

  @observable bool shouldShowOperators = false;
  @observable bool shouldShowVariables = false;
  @observable bool shouldShowStaticVariables = false;
  @observable bool shouldShowConstructors = false;
  @observable bool shouldShowFunctions = false;
  @observable bool shouldShowStaticFunctions = false;

  void showSubclass(event, detail, target) {
    for (var e in shadowRoot.querySelectorAll('.hidden')) {
      e.classes.remove('hidden');
    }
    shadowRoot.querySelector('#subclass-button').classes.add('hidden');
  }

  onChangeShowInherited() {
    bool shouldShow(Category c) => c.content.isNotEmpty &&
        (viewer.isInherited || c.hasNonInherited);

    shouldShowOperators = shouldShow(item.operators);
    shouldShowVariables = shouldShow(item.variables);
    shouldShowStaticVariables = shouldShow(item.staticVariables);
    shouldShowConstructors = shouldShow(item.constructors);
    shouldShowFunctions = shouldShow(item.functions);
    shouldShowStaticFunctions = shouldShow(item.staticFunctions);
  }

  itemChanged() {
    super.itemChanged();

    onChangeShowInherited();

    if (shadowRoot != null) {
      addInterfaces();
      addSubclasses();
    }
  }

  addInterfaces() {
    var p = shadowRoot.querySelector("#interfaces");
    if (p == null) return;
    p.children.clear();
    if (item.interfaces.isNotEmpty) {
      p.appendText('Implements: ');
      makeLinks(item.interfaces).forEach(p.append);
      p.appendText(' ');
    }
    if (item.superClass != null) {
      p.appendText('Extends: ');
      makeLinks([item.superClass]).forEach(p.append);
    }
  }

  addSubclasses() {
    if (item.qualifiedName == 'dart.core.Object') return;

    var p = shadowRoot.querySelector("#subclasses");
    p.children.clear();
    final subclasses = item.subclasses;
    var links = makeLinks(subclasses.take(MAX_SUBCLASSES_TO_SHOW));
    if (subclasses.isNotEmpty) {
      p.appendText('Subclasses: ');
      links.forEach(p.append);
    }
    if (subclasses.length <= MAX_SUBCLASSES_TO_SHOW) return;
    var ellipsis = new AnchorElement()
      ..classes = ["btn", "btn-link", "btn-xs"]
      ..id = "subclass-button"
      ..text = "..."
      ..onClick.listen((event) => showSubclass(null, null, null));
    p.append(ellipsis);
    makeLinks(subclasses.skip(MAX_SUBCLASSES_TO_SHOW), hidden: true)
        .forEach(p.append);
  }

  /// Make links for subclasses, interfaces, etc. comma-separated, and hidden
  /// initially if [hidden] is true. Also assume that if [hidden] is false
  /// we should suppress the first comma.
  makeLinks(Iterable classes, {hidden : false}) {
    var first = !hidden;
    return classes.map((cls) => makeLink(cls, hidden: hidden)).fold([],
        (list, classLink) {
          if (first) {
            first = false;
          } else {
            list.add(
                new SpanElement()
                  ..text = ', '
                  ..id = 'subclass-hidden'
                  ..classes = hidden ? ['hidden'] : []);
          }
          list.add(classLink);
          return list;
    });
  }

  makeLink(cls, {hidden : false}) =>
    new AnchorElement()
      ..href = "#${cls.location}"
      ..id = 'subclass-hidden'
      ..classes = (hidden ? ['hidden'] : [])
      ..text = cls.simpleType;
}