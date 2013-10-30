// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library method_panel;

import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';
import 'package:dartdoc_viewer/item.dart';

@CustomTag("method-panel")
class MethodPanel extends MethodElement {
  MethodPanel.created() : super.created() {
    style.setProperty('display', 'block');
  }

  get observables => concat(super.observables,
      const [#annotations, #modifiers, #shouldShowMethodComment,
      #parameters, #isInherited, #hasInheritedComment]);
  get methodsToCall => concat(super.methodsToCall, const [#createType]);

  wrongClass(newItem) => newItem is! Method;

  createType(NestedType type, String memberName, String className) {
    if (!item.isConstructor) {
      super.createType(type, memberName, className);
    }
  }

  set item(x) => super.item = x;
  get item => super.item;

  @observable String get modifiers =>
      constantModifier + staticModifier;
  @observable get constantModifier => item.isConstant ? 'const' : '';
  @observable get abstractModifier => item.isAbstract ? 'abstract' : '';
  @observable get staticModifier => item.isStatic ? 'static' : '';
  @observable get annotations => item.annotations;

  @observable get shouldShowMethodComment =>
    item != null && item.comment != '<span></span>';
}