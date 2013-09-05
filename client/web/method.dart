library method;

import 'app.dart';
import 'member.dart';
import 'package:polymer/polymer.dart';

// TODO(alanknight): These pages are almost impossible to get to right now.
// We should either delete them or make them navigable.
@CustomTag("dartdoc-method")
class DartdocMethod extends MethodElement {
  DartdocMethod() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #annotations);
          notifyProperty(this, #modifiers);
          notifyProperty(this, #shouldShowMethodComment);
          notifyProperty(this, #createMethodType);
        });
  }

  get item => super.item;
  set item(x) => super.item = x;

  void createMethodType() {
    if (!item.isConstructor) {
      createType(item.type, 'dartdoc-method', 'type');
    }
  }

  @observable String get modifiers => constantModifier + abstractModifier
      + staticModifier;
  get constantModifier => item.isConstant ? 'const' : '';
  get abstractModifier => item.isAbstract ? 'abstract' : '';
  get staticModifier => item.isStatic ? 'static' : '';
  @observable get annotations => item.annotations;
  @observable get shouldShowMethodComment =>
    item != null && item.comment != '<span></span>';
}