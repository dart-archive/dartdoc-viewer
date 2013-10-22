library variable;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/item.dart';
import 'app.dart' as app;
import 'member.dart';

/**
 * An HTML representation of a Variable.
 */
@CustomTag("dartdoc-variable")
class VariableElement extends InheritedElement {
  VariableElement.created() : super.created() {
    style.setProperty('display', 'block');
  }

  get observables => concat(super.observables, const [#annotations]);
  get defaultItem => new Variable({'type' : [null]})..name = 'loading';
  wrongClass(newItem) => newItem is! Variable;

  get item => super.item;
  set item(newItem) => super.item = newItem;

  @observable get annotations =>
      item == null ? new AnnotationGroup([]) : item.annotations;
}