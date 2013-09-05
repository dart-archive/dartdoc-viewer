library class_;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';

import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-class")
class ClassElement extends MemberElement {
  ClassElement() {
    item = new Class.forPlaceholder('loading', 'loading');
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #variables);
          notifyProperty(this, #operators);
          notifyProperty(this, #constructors);
          notifyProperty(this, #methods);
          notifyProperty(this, #annotations);
          notifyProperty(this, #interfaces);
          notifyProperty(this, #subclasses);
          notifyProperty(this, #superClass);
          notifyProperty(this, #nameWithGeneric);
          notifyProperty(this, #name);
          notifyProperty(this, #addInterfaceLinks);
          notifyProperty(this, #addSubclassLinks);
          notifyProperty(this, #isNotObject);
        });
  }

  set item(newItem) => super.item = (newItem is Class) ? newItem : item;
  @observable Class get item => super.item;

  @observable Category get variables => item.variables;

  @observable Category get operators => item.operators;

  @observable Category get constructors => item.constructs;

  @observable Category get methods => item.functions;

  @observable AnnotationGroup get annotations => item.annotations;
  set annotations(_) {}

  @observable List<LinkableType> get interfaces =>
      item == null ? [] : item.implements;
  @observable List<LinkableType> get subclasses => item.subclasses;

  @observable LinkableType get superClass => item.superClass;

  void showSubclass(event, detail, target) {
    shadowRoot.query('#${item.name}-subclass-hidden').classes
        .remove('hidden');
    shadowRoot.query('#${item.name}-subclass-button').classes.add('hidden');
  }

  @observable String get nameWithGeneric => item.nameWithGeneric;
  @observable String get name => item.name;

  @observable bool get isNotObject => item.qualifiedName != 'dart.core.Object';

  @observable addExtraSubclassLinks() {
    makeLinks(subclasses.skip(3));
  }

  @observable addInterfaceLinks() {
    var p = shadowRoot.query("#interfaces");
    if (p == null) return;
    p.children.clear();
    if (interfaces.isNotEmpty) {
      p.append(p.createFragment('Implements:&nbsp;' + makeLinks(interfaces)
                              + '&nbsp;'));
    }
    if (superClass != null) {
      p.append(p.createFragment('Extends:&nbsp;' + makeLinks([superClass])));
    }
  }

  @observable addSubclassLinks() {
    var p = shadowRoot.query("#subclasses");
    // Remove all the children except the '...' button, which we can't
    // create dynamically because the on-click handler won't get registered.
    var buttonThatMustBeStatic = p.query(".btn-link");
    p.children.clear();
    var text = makeLinks(subclasses.take(3));
    if (subclasses.isEmpty) {
      buttonThatMustBeStatic.classes.add("hidden");
    } else {
      p.append(p.createFragment('Subclasses: ' + text,
          treeSanitizer: sanitizer));
      buttonThatMustBeStatic.classes.remove("hidden");
    }
    p.append(buttonThatMustBeStatic);
    if (subclasses.length <= 3) return;
    p.append(p.createFragment(
         '<span id="${item.name}-subclass-hidden" class="hidden">,&nbsp;'
         '</span>', treeSanitizer: sanitizer));
    var q = shadowRoot.query("#${item.name}-subclass-hidden");
    q.append(q.createFragment(makeLinks(subclasses.skip(3))));
  }

  makeLinks(Iterable classes) =>
    classes
        .map((cls) =>'<a href="#${cls.location}">${cls.simpleType}</a>')
        .join(",&nbsp;");
}