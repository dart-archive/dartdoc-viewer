// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library typedef;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-typedef")
class TypedefElement extends MemberElement {
  TypedefElement.created() : super.created();

  get observables => concat(super.observables,
      const [#required, #optional, #annotations, #name,
      #location, #simpleType, #parameters]);
  wrongClass(newItem) => newItem is! Typedef;
  get defaultItem =>
      new Typedef({'name' : 'loading', 'qualifiedName' : 'loading'});

  get item => super.item;
  set item(newItem) => super.item = newItem;

  @observable get name => check(() => item.name);
  @observable get location => check(() => item.type.location);
  @observable get simpleType => check(() => item.type.simpleType);
  @observable get parameters => check(() => item.parameters, []);

  check(f, [orElse = '']) => item == null ? orElse : f();

  // Required parameters.
  @observable List<Parameter> get required =>
    item.parameters.where((parameter) => !parameter.isOptional).toList();

  // Optional parameters.
  @observable List<Parameter> get optional =>
    item.parameters.where((parameter) => parameter.isOptional).toList();

  @observable get annotations =>
      check(() => item.annotations, new AnnotationGroup([]));
}