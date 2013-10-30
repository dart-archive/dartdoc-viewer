// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library item;

import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/item.dart';

import 'app.dart' as app;
import 'member.dart';
import 'dart:html';

/**
 * An HTML representation of a Item.
 *
 * Used as a placeholder for an CategoryItem object.
 */
 @CustomTag("dartdoc-item")
class ItemElement extends MemberElement {
  ItemElement.created() : super.created() {
    style.setProperty('display', 'block');
  }

  get observables => concat(super.observables,
      const [#title, #parameters, #type, #linkHref, #isMethod,
      #modifiers, #shouldShowClassOrLibraryComment, #shouldShowMethodComment,
      #idName]);

  get methodsToCall => concat(super.methodsToCall, const [#addChildren]);

  wrongClass(newItem) => newItem is! Item;

  get defaultItem =>
      new Class.forPlaceholder("loading.loading", "loading");

  get item => super.item;
  set item(newItem) => super.item = newItem;

  @observable get linkHref => item.linkHref;
  @observable String get title => item.decoratedName;

  @observable get parameters => item is Method ? item.parameters : [];
  @observable get type => item is Method ? item.type : null;

  @observable get isMethod => item is Method;
  @observable get isConstructor => isMethod && item.isConstructor;

  @observable String get modifiers {
    if (item is! Method) return '';
    return constantModifier + abstractModifier + staticModifier;
  }
  @observable get constantModifier => item.isConstant ? 'const' : '';
  @observable get abstractModifier => item.isAbstract ?'abstract' : '';
  @observable get staticModifier => item.isStatic ? 'static' : '';

  @observable get shouldShowClassOrLibraryComment =>
      (item is Class || item is Library) && item.previewComment != null;
  @observable get shouldShowMethodComment =>
      item is Method && item.comment != '<span></span>';

  enteredView() {
    super.enteredView();
    addChildren();
  }

  addChildren() {
    // TODO(alanknight): Some of what was being done in the template is nicer
    // in code, but it would be much better if we could move some of this
    // back to a template once performance improves.
    var out = new StringBuffer();
    var mainAnchor = new AnchorElement()
      ..href = "#$linkHref"
      ..id = idName;
    if (!isMethod) {
      mainAnchor.appendText(title);
    } else if (isMethod && !isConstructor) {
      if (item.type != null && !item.type.isDynamic) {
        var returnType = new SpanElement()
          ..classes.add("type");
        returnType.append(MemberElement.createInner(item.type));
        mainAnchor.append(returnType);
      }
      var signature = new SpanElement();
      signature.appendText(modifiers);
      var decoratedName = new Element.html('<b>${item.decoratedName}</b>');
      signature.append(decoratedName);
      var params = document.createElement('dartdoc-parameter');
      params.parameters = parameters;
      signature.append(params);
      mainAnchor.append(signature);
    }

    var root = shadowRoot.querySelector("#nameGoesHere");
    root.children.clear();
    root.append(mainAnchor);

    if (shouldShowClassOrLibraryComment) {
      var commentary = [new Element.html('<hr/>')];
      commentary.add(new Element.html('<p class="description"></p>'));
      addComment('dartdoc-item', true, commentary.last);
      root.children.addAll(commentary);
    }
    if (shouldShowMethodComment) {
      var commentary = [new Element.html('<hr/>')];
      commentary.add(new Element.html('<p class="description"></p>' +
          'id=${item.name}-method-comment'));
      addComment('dartdoc-item', true, commentary.last);
      root.children.addAll(commentary);
    }
  }
}