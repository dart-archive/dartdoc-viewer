library method_panel;

import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';
import 'package:dartdoc_viewer/item.dart';

@CustomTag("method-panel")
class MethodPanel extends MethodElement {
  MethodPanel() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #annotations);
          notifyProperty(this, #modifiers);
          notifyProperty(this, #shouldShowMethodComment);
          notifyProperty(this, #createType);
          notifyProperty(this, #parameters);
          notifyProperty(this, #isInherited);
          notifyProperty(this, #hasInheritedComment);
        });
  }

  createType(NestedType type, String memberName, String className) {
    if (!item.isConstructor) {
      super.createType(type, memberName, className);
    }
  }

  set item(x) => super.item = x;
  get item => super.item;

  @observable String get modifiers =>
      constantModifier + abstractModifier + staticModifier;
  @observable get constantModifier => item.isConstant ? 'const' : '';
  @observable get abstractModifier => item.isAbstract ? 'abstract' : '';
  @observable get staticModifier => item.isStatic ? 'static' : '';
  @observable get annotations => item.annotations;

  @observable get shouldShowMethodComment =>
    item != null && item.comment != '<span></span>';
}