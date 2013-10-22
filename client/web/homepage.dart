library homepage;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'dart:html';
import 'member.dart';

@CustomTag("dartdoc-homepage")
class HomeElement extends MemberElement {
  HomeElement.created() : super.created();

  get defaultItem => null;
  get observables => concat(super.observables, const [#libraries]);
  wrongClass(newItem) => newItem is! Home;

  get item => super.item;
  set item(newItem) => super.item = newItem;

  get methodsToCall => concat(super.methodsToCall, const [#addChildren]);

  @observable get libraries => item == null ? [] : item.libraries;

  enteredView() {
    super.enteredView();
    addChildren();
  }

  /// Dynamically generate elements for all of our libraries, for performance
  /// reasons.
  addChildren() {
    // TODO(alanknight): Move this and other occurences of addChildren back
    // into templates if they get acceptable performance.
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