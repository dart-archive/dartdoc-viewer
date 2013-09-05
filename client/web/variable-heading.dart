library variable_heading;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/item.dart';
import 'app.dart' as app;
import 'member.dart';

/**
 * An HTML representation of a Variable.
 */
@CustomTag("variable-heading")
class VariableHeading extends MemberElement {
  VariableHeading() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #getter);
          notifyProperty(this, #setterParameter);
          notifyProperty(this, #type);
          notifyProperty(this, #name);
          notifyProperty(this, #idName);
        });
  }

  Variable get item => super.item;
  set item(newItem) => super.item = newItem;

  @observable String get getter => item != null && item.isGetter ? 'get' : '';

  @observable Parameter get setterParameter => item.setterParameter;

  @observable NestedType get type => item.type;

  @observable String get name => item == null ? '' : nameWithoutSetter;
  @observable String get nameWithoutSetter =>
      item.isSetter ? item.name.substring(0, item.name.length - 1) : item.name;
}