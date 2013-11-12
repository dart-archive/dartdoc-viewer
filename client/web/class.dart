// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library class_;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';
@MirrorsUsed()
import 'dart:mirrors';
import 'dart:html';

@CustomTag("dartdoc-class")
class ClassElement extends MemberElement {

  static const MAX_SUBCLASSES_TO_SHOW = 3;

  ClassElement.created() : super.created() {
    new PathObserver(viewer, "isInherited").changes.listen((changes) {
      notifyPropertyChange(#shouldShowOperators, null, true);
      notifyPropertyChange(#shouldShowVariables, null, true);
      notifyPropertyChange(#shouldShowConstructors, null, true);
      notifyPropertyChange(#shouldShowMethods, null, true);
      notifyPropertyChange(#variables, null, []);
      notifyPropertyChange(#operators, null, []);
      notifyPropertyChange(#constructors, null, []);
      notifyPropertyChange(#methods, null, []);
    });
  }

  get defaultItem => new Class.forPlaceholder('loading.loading', 'loading');

  get observables => concat(super.observables,
    const [#variables, #operators, #constructors, #methods, #staticMethods,
    #staticVariables, #annotations, #interfaces, #subclasses, #superClass,
    #nameWithGeneric, #name, #isNotObject,
    #shouldShowOperators, #shouldShowVariables, #shouldShowConstructors,
    #shouldShowMethods, #shouldShowStaticMethods, #shouldShowStaticVariables]);

  get methodsToCall => concat(super.methodsToCall,
      const [#addInterfaceLinks, #addSubclassLinks]);

  bool wrongClass(newItem) => newItem is! Class;

  get item => super.item;
  set item(newItem) => super.item = newItem;

  @observable Category get variables => item.instanceVariables;
  @observable Category get operators => item.operators;
  @observable Category get constructors => item.constructs;
  @observable Category get methods => item.instanceFunctions;
  @observable Category get staticMethods => item.staticFunctions;
  @observable Category get staticVariables => item.staticVariables;
  @observable bool get shouldShowOperators => shouldShow(operators);
  @observable bool get shouldShowVariables =>  shouldShow(variables);
  @observable bool get shouldShowStaticVariables => shouldShow(staticVariables);
  @observable bool get shouldShowConstructors =>  shouldShow(constructors);
  @observable bool get shouldShowMethods =>  shouldShow(methods);
  @observable bool get shouldShowStaticMethods =>  shouldShow(staticMethods);
  @observable bool shouldShow(Category thing) =>
      thing.content.isNotEmpty &&
      (viewer.isInherited || thing.hasNonInherited);

  @observable AnnotationGroup get annotations => item.annotations;
  set annotations(_) {}

  @observable List<LinkableType> get interfaces =>
      item == null ? [] : item.implements;
  @observable List<LinkableType> get subclasses => item.subclasses;

  @observable LinkableType get superClass => item.superClass;

  void showSubclass(event, detail, target) {
    var hidden = shadowRoot.querySelectorAll('.hidden').toList();
    hidden.forEach((element) =>
        element.classes.remove('hidden'));
    shadowRoot.querySelector(
        '#subclass-button').classes.add('hidden');
  }

  @observable String get nameWithGeneric => item.nameWithGeneric;
  @observable String get name => item.name;

  @observable bool get isNotObject => item.qualifiedName != 'dart.core.Object';

  @observable addExtraSubclassLinks() {
    makeLinks(subclasses.skip(MAX_SUBCLASSES_TO_SHOW));
  }

  @observable addInterfaceLinks() {
    var p = shadowRoot.querySelector("#interfaces");
    if (p == null) return;
    p.children.clear();
    if (interfaces.isNotEmpty) {
      p.append(new Text('Implements: '));
      makeLinks(interfaces).forEach(p.append);
      p.appendText(' ');
    }
    if (superClass != null) {
      p.append(new Text('Extends: '));
      makeLinks([superClass]).forEach(p.append);
    }
  }

  @observable addSubclassLinks() {
    if (shadowRoot == null) return;
    var p = shadowRoot.querySelector("#subclasses");
    p.children.clear();
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