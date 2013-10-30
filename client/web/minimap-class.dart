// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library minimap_class;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';
import 'member.dart';
import 'dart:html';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-minimap-class")
class MinimapElementClass extends MemberElement {
  MinimapElementClass.created() : super.created() {
    new PathObserver(this, "viewer.isInherited").bindSync(
        (_) {
          notifyPropertyChange(#shouldShowConstructors, null,
              shouldShowConstructors);
          notifyPropertyChange(#shouldShowOperators, null,
              shouldShowConstructors);
          notifyPropertyChange(#shouldShowFunctions, null,
              shouldShowConstructors);
          notifyPropertyChange(#shouldShowVariables, null,
                  shouldShowConstructors);
        });
  }

  get observables => concat(super.observables, const [#operatorItems,
      #variableItems, #constructorItems,
      #functionItems, #operators, #variables, #constructors, #functions,
      #operatorItemsIsNotEmpty, #variableItemsIsNotEmpty,
      #constructorItemsIsNotEmpty, #functionItemsIsNotEmpty, #page,
      #shouldShowConstructors, #shouldShowFunctions, #shouldShowVariables,
      #shouldShowOperators, #name, #currentLocation, #linkHref]);

  wrongClass(newItem) => newItem is! Class;

  get defaultItem => new Class.forPlaceholder('loading.loading', 'loading');

  @observable get operatorItems => page.operators.content;
  @observable get variableItems => page.variables.content;
  @observable get constructorItems => page.constructs.content;
  @observable get functionItems => page.functions.content;

  @observable get operators => page.operators;
  @observable get variables => page.variables;
  @observable get constructors => page.constructs;
  @observable get functions => page.functions;

  @observable get operatorItemsIsNotEmpty => _isNotEmpty(operators);
  @observable get variableItemsIsNotEmpty => _isNotEmpty(variables);
  @observable get constructorItemsIsNotEmpty => _isNotEmpty(constructors);
  @observable get functionItemsIsNotEmpty => _isNotEmpty(functions);

  _isNotEmpty(x) => x == null || page is! Class ? false : x.content.isNotEmpty;

  @observable get page => item;
  @observable get linkHref => item.linkHref;

  get item => super.item;
  set item(newItem) => super.item = newItem;

  @observable get shouldShowConstructors => shouldShow((x) => x.constructors);
  @observable get shouldShowFunctions => shouldShow((x) => x.functions);
  @observable get shouldShowVariables => shouldShow((x) => x.variables);
  @observable get shouldShowOperators {
    var result = shouldShow((x) => x.operators);
    return result;
  }

  shouldShow(Function f) => page is Class &&
      (f(page).hasNonInherited ||  viewer.isInherited);

  @observable get name => page.name;

  @observable get currentLocation => window.location.toString();

  hideShow(event, detail, target) {
    var list = shadowRoot.querySelector(
        "#minimap-" + target.hash.split("#").last);
    if (list.classes.contains("in")) {
      list.classes.remove("in");
    } else {
      list.classes.add("in");
    }
  }
}