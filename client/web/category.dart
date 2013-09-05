library category;


import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/item.dart';
import 'app.dart';
import 'member.dart';
import 'dart:html';

/**
 * An HTML representation of a Category.
 *
 * Used as a placeholder for an CategoryItem object.
 */
 @CustomTag("dartdoc-category")
class CategoryElement extends DartdocElement {

  CategoryElement() {
    new PathObserver(this, "category.name").bindSync(
        (_) {
          notifyProperty(this, #title);
          notifyProperty(this, #stylizedName);
        });
    new PathObserver(viewer, "isDesktop").bindSync(
        (_) {
          notifyProperty(this, #accordionStyle);
          notifyProperty(this, #accordionParent);
          notifyProperty(this, #divClass);
          notifyProperty(this, #divStyle);
          notifyProperty(this, #currentLocation);
        });
    new PathObserver(this, "category").bindSync(
        (_) {
          _flushCache();
          notifyProperty(this, #categoryContent);
          notifyProperty(this, #categoryVariables);
          notifyProperty(this, #categoryMethods);
          notifyProperty(this, #categoryEverythingElse);
          notifyProperty(this, #currentLocation);
        });
  }

  @observable Container category;

  @observable String get title => category == null ? '' : category.name;

  @observable String get stylizedName =>
      category == null ? '' : category.name.replaceAll(' ', '-');

  @observable get categoryContent => category == null ? [] : category.content;

  @observable get categoryMethods {
    if (_methodsCache != null) return _methodsCache;
    _methodsCache = categoryContent.where((each) => each is Method).toList();
    return _methodsCache;
  }

  @observable get categoryVariables {
    if (_variablesCache != null) return _variablesCache;
    _variablesCache = categoryContent.where(
        (each) => each is Variable).toList();
    return _variablesCache;
  }

  @observable get categoryEverythingElse {
    if (_everythingElseCache != null) return _everythingElseCache;
    _everythingElseCache = categoryContent.where(
        (each) => each is! Variable && each is! Method).toList();
    return _everythingElseCache;
  }
  var _methodsCache = null;
  var _variablesCache = null;
  var _everythingElseCache = null;

  _flushCache() {
    _methodsCache = null;
    _variablesCache = null;
    _everythingElseCache = null;
  }

  @observable get accordionStyle => viewer.isDesktop ? '' : 'collapsed';
  @observable get accordionParent =>
      viewer.isDesktop ? '' : '#accordion-grouping';

  @observable get divClass => viewer.isDesktop ? 'collapse in' : 'collapse';
  @observable get divStyle => viewer.isDesktop ? 'auto' : '0px';

  var validator = new NodeValidatorBuilder()
    ..allowHtml5(uriPolicy: new SameProtocolUriPolicy())
    ..allowCustomElement("method-panel", attributes: ["item"])
    ..allowCustomElement("dartdoc-item", attributes: ["item"])
    ..allowCustomElement("dartdoc-variable", attributes: ["item"])
    ..allowCustomElement("dartdoc-category-interior", attributes: ["item"])
    ..allowTagExtension("method-panel", "div", attributes: ["item"]);

  hideShow(event, detail, target) {
    var list = shadowRoot.query("#" + target.hash.split("#").last);
    if (list.classes.contains("in")) {
      list.classes.remove("in");
      list.style.height = '0px';
    } else {
      list.classes.add("in");
      list.style.height = 'auto';
    }
  }

  @observable get currentLocation => window.location;
}