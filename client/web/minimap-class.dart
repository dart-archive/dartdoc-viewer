// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library minimap_class;

import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/location.dart';
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
      #staticVariables, #staticFunctions, #staticFunctionItems,
      #staticVariableItems,
      #operatorItemsIsNotEmpty, #variableItemsIsNotEmpty,
      #staticVariableItemsIsNotEmpty, #staticFunctionItemsIsNotEmpty,
      #constructorItemsIsNotEmpty, #functionItemsIsNotEmpty, #page,
      #shouldShowConstructors, #shouldShowFunctions, #shouldShowVariables,
      #shouldShowOperators, #shouldShowStaticFunctions,
      #shouldShowStaticVariables, #name, #currentLocation, #linkHref]);

  wrongClass(newItem) => newItem is! Class;

  get defaultItem => new Class.forPlaceholder('loading.loading', 'loading');

  @observable get operatorItems => page.operators.content;
  @observable get variableItems => page.instanceVariables.content;
  @observable get staticVariableItems => page.staticVariables.content;
  @observable get constructorItems => page.constructs.content;
  @observable get functionItems => page.instanceFunctions.content;
  @observable get staticFunctionItems => page.staticFunctions.content;

  @observable get operators => page.operators;
  @observable get variables => page.instanceVariables;
  @observable get staticVariables => page.staticVariables;
  @observable get constructors => page.constructs;
  @observable get functions => page.instanceFunctions;
  @observable get staticFunctions => page.staticFunctions;

  @observable get operatorItemsIsNotEmpty => _isNotEmpty(operators);
  @observable get variableItemsIsNotEmpty => _isNotEmpty(variables);
  @observable get staticVariableItemsIsNotEmpty => _isNotEmpty(staticVariables);
  @observable get constructorItemsIsNotEmpty => _isNotEmpty(constructors);
  @observable get functionItemsIsNotEmpty => _isNotEmpty(functions);
  @observable get staticFunctionItemsIsNotEmpty => _isNotEmpty(staticFunctions);

  _isNotEmpty(x) => x == null || page is! Class ? false : x.content.isNotEmpty;

  @observable Class get page => item;
  @observable get linkHref => item.linkHref;

  Class get item => super.item;
  set item(newItem) => super.item = newItem;

  @observable get shouldShowConstructors => shouldShow((x) => x.constructors);
  @observable get shouldShowFunctions => shouldShow((x) => x.functions);
  @observable get shouldShowVariables => shouldShow((x) => x.variables);
  @observable get shouldShowStaticFunctions
      => shouldShow((x) => x.staticFunctions);
  @observable get shouldShowStaticVariables
      => shouldShow((x) => x.staticVariables);
  @observable get shouldShowOperators => shouldShow((x) => x.operators);

  shouldShow(Function f) => page is Class &&
      (f(page).hasNonInherited ||  viewer.isInherited);

  @observable get name => page.decoratedName;

  @observable get currentLocation => window.location.toString();

  hideShow(event, detail, target) {
    var loc = new DocsLocation(target.hash);
    var list = shadowRoot.querySelector(
        "#minimap-" + loc.anchor);
    if (list.classes.contains("in")) {
      list.classes.remove("in");
    } else {
      list.classes.add("in");
    }
  }
}