library item;

import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/item.dart';

import 'app.dart' as app;
import 'member.dart';

/**
 * An HTML representation of a Item.
 *
 * Used as a placeholder for an CategoryItem object.
 */
 @CustomTag("dartdoc-item")
class ItemElement extends MemberElement {
  ItemElement() {
    item = defaultItem();
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #title);
          notifyProperty(this, #parameters);
          notifyProperty(this, #type);
          notifyProperty(this, #linkHref);
          notifyProperty(this, #isMethod);
          notifyProperty(this, #modifiers);
          notifyProperty(this, #shouldShowClassOrLibraryComment);
          notifyProperty(this, #shouldShowMethodComment);
          notifyProperty(this, #idName);
        });
  }

  get item => super.item;
  set item(x) => super.item = (x == null || x is! Item) ? defaultItem() : x;

  defaultItem() => new Class.forPlaceholder("<p>loading</p>", "<p>loading</p>");

  @observable get linkHref => item.linkHref;
  @observable String get title => item.decoratedName;

  @observable get parameters => item is Method ? item.parameters : [];
  @observable get type => item is Method ? item.type : null;

  @observable get isMethod => item is Method;
  @observable get isConstructor => isMethod && item.isConstructor;

  @observable String get modifiers {
    if (item is! Method) return '';
    return constantModifier + abstractModifier + staticModifier;
  }
  @observable get constantModifier => item.isConstant ? 'const' : '';
  @observable get abstractModifier => item.isAbstract ?'abstract' : '';
  @observable get staticModifier => item.isStatic ? 'static' : '';

  @observable get shouldShowClassOrLibraryComment =>
      (item is Class || item is Library) && item.previewComment != null;
  @observable get shouldShowMethodComment =>
      item is Method && item.comment != '<span></span>';
 }