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

  CategoryElement.created() : super.created() {
    new PathObserver(viewer, "isDesktop").changes.listen((changes) {
      var change = changes.first;
      notifyPropertyChange(
          #accordionStyle, accordionStyleFor(change.oldValue), accordionStyle);
      notifyPropertyChange(#accordionParent,
          accordionParentFor(change.oldValue), accordionParent);
      notifyPropertyChange(#divClass, divClassFor(change.oldValue), divClass);
      notifyPropertyChange(#divStyle, divStyleFor(change.oldValue), divStyle);
    });
    style.setProperty('display', 'block');
  }

  addChildren() {
    var elements = [];
    var types = {
      'dartdoc-variable' : categoryVariables,
      'dartdoc-item' : categoryEverythingElse,
      'method-panel' : categoryMethods
    };
    types.forEach((tagName, items) {
      for (var subItem in items) {
        var newItem = document.createElement(tagName);
        newItem.item = subItem;
        newItem.classes.add("panel");
        elements.add(newItem);
      }
    });
    var root = shadowRoot.querySelector("#itemList");
    root.children.clear();
    root.children.addAll(elements);
  }

  get observables => concat(super.observables,
    const [#category, #categoryContent, #categoryVariables,
    #categoryMethods, #categoryEverythingElse, #currentLocation, #title,
    #stylizedName]);

  Container _category;
  @published Container get category => _category;
  @published set category(newCategory) {
    if (newCategory == null || newCategory is! Container ||
        newCategory == _category) return;
    _flushCache();
    notifyObservables(() {
      _category = newCategory;
      _flushCache();
    });
    addChildren();
  }

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

  @observable get accordionStyle => accordionStyleFor(viewer.isDesktop);
  accordionStyleFor(isDesktop) => isDesktop ? '' : 'collapsed';
  @observable get accordionParent => accordionParentFor(viewer.isDesktop);
  accordionParentFor(isDesktop) => isDesktop ? '' : '#accordion-grouping';

  @observable get divClass => divClassFor(viewer.isDesktop);
  divClassFor(isDesktop) => isDesktop ? 'collapse in' : 'collapse';
  @observable get divStyle => divStyleFor(viewer.isDesktop);
  divStyleFor(isDesktop) => isDesktop ? 'auto' : '0px';


  var validator = new NodeValidatorBuilder()
    ..allowHtml5(uriPolicy: new SameProtocolUriPolicy())
    ..allowCustomElement("method-panel", attributes: ["item"])
    ..allowCustomElement("dartdoc-item", attributes: ["item"])
    ..allowCustomElement("dartdoc-variable", attributes: ["item"])
    ..allowCustomElement("dartdoc-category-interior", attributes: ["item"])
    ..allowTagExtension("method-panel", "div", attributes: ["item"]);

  hideShow(event, detail, target) {
    var list = shadowRoot.querySelector("#" + target.hash.split("#").last);
    if (list.classes.contains("in")) {
      list.classes.remove("in");
      list.style.height = '0px';
    } else {
      list.classes.add("in");
      list.style.height = 'auto';
    }
  }

  @observable get currentLocation => window.location.toString();
}