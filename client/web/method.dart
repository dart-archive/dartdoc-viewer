library method;

import 'app.dart';
import 'member.dart';
import 'package:polymer/polymer.dart';

// TODO(alanknight): These pages are almost impossible to get to right now.
// We should either delete them or make them navigable.
@CustomTag("dartdoc-method")
class DartdocMethod extends MethodElement {
  DartdocMethod.created() : super.created();

  get observables => concat(super.observables,
      const [#annotations, #modifiers, #shouldShowMethodComment]);
  get methodsToCall => concat(super.methodsToCall, const [#createMethodType]);

  get item => super.item;
  set item(x) => super.item = x;

  void createMethodType() {
    if (!item.isConstructor) {
      createType(item.type, 'dartdoc-method', 'type');
    }
  }

  @observable String get modifiers => constantModifier
      + staticModifier;
  get constantModifier => item.isConstant ? 'const' : '';
  get abstractModifier => item.isAbstract ? 'abstract' : '';
  get staticModifier => item.isStatic ? 'static' : '';
  @observable get annotations => item.annotations;
  @observable get shouldShowMethodComment =>
    item != null && item.comment != '<span></span>';
}