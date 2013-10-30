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

@CustomTag("dartdoc-class")
class ClassElement extends MemberElement {
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
    const [#variables, #operators, #constructors, #methods,
    #annotations, #interfaces, #subclasses, #superClass,
    #nameWithGeneric, #name, #isNotObject,
    #shouldShowOperators, #shouldShowVariables, #shouldShowConstructors,
    #shouldShowMethods]);

  get methodsToCall => concat(super.methodsToCall,
      const [#addInterfaceLinks, #addSubclassLinks]);

  bool wrongClass(newItem) => newItem is! Class;

  get item => super.item;
  set item(newItem) => super.item = newItem;

  @observable Category get variables => item.variables;
  @observable Category get operators => item.operators;
  @observable Category get constructors => item.constructs;
  @observable Category get methods => item.functions;
  @observable bool get shouldShowOperators => shouldShow(operators);
  @observable bool get shouldShowVariables =>  shouldShow(variables);
  @observable bool get shouldShowConstructors =>  shouldShow(constructors);
  @observable bool get shouldShowMethods =>  shouldShow(methods);
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
    shadowRoot.querySelector('#${item.name}-subclass-hidden').classes
        .remove('hidden');
    shadowRoot.querySelector(
        '#${item.name}-subclass-button').classes.add('hidden');
  }

  @observable String get nameWithGeneric => item.nameWithGeneric;
  @observable String get name => item.name;

  @observable bool get isNotObject => item.qualifiedName != 'dart.core.Object';

  @observable addExtraSubclassLinks() {
    makeLinks(subclasses.skip(3));
  }

  @observable addInterfaceLinks() {
    var p = shadowRoot.querySelector("#interfaces");
    if (p == null) return;
    p.children.clear();
    if (interfaces.isNotEmpty) {
      p.append(p.createFragment('Implements:&nbsp;' + makeLinks(interfaces)
                              + '&nbsp;'));
    }
    if (superClass != null) {
      p.append(p.createFragment('Extends:&nbsp;' + makeLinks([superClass])));
    }
  }

  @observable addSubclassLinks() {
    if (shadowRoot == null) return;
    var p = shadowRoot.querySelector("#subclasses");
    // Remove all the children except the '...' button, which we can't
    // create dynamically because the on-click handler won't get registered.
    var buttonThatMustBeStatic = p.querySelector(".btn-link");
    p.children.clear();
    var text = makeLinks(subclasses.take(3));
    // TODO(alanknight) : I don't understand how we can have the #subclasses
    // template element but not the .btn-link one, but it seems to happen.
    if (subclasses.isEmpty) {
      if (buttonThatMustBeStatic != null) {
        buttonThatMustBeStatic.classes.add("hidden");
      }
    } else {
      p.append(p.createFragment('Subclasses: ' + text,
          treeSanitizer: sanitizer));
      if (buttonThatMustBeStatic != null) {
        buttonThatMustBeStatic.classes.remove("hidden");
      }
    }
    if (subclasses.length <= 3) return;
    p.append(buttonThatMustBeStatic);
    p.append(p.createFragment(
         '<span id="${item.name}-subclass-hidden" class="hidden">,&nbsp;'
         '</span>', treeSanitizer: sanitizer));
    var q = shadowRoot.querySelector("#${item.name}-subclass-hidden");
    q.append(q.createFragment(makeLinks(subclasses.skip(3))));
  }

  makeLinks(Iterable classes) =>
    classes
        .map((cls) =>'<a href="#${cls.location}">${cls.simpleType}</a>')
        .join(",&nbsp;");
}