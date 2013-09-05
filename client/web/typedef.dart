library typedef;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-typedef")
class TypedefElement extends MemberElement {
  TypedefElement() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #required);
          notifyProperty(this, #optional);
          notifyProperty(this, #annotations);
          notifyProperty(this, #name);
          notifyProperty(this, #location);
          notifyProperty(this, #simpleType);
          notifyProperty(this, #parameters);
        });
  }

  Typedef get item => super.item;
  set item(x) => super.item = x;

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