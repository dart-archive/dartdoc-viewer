library category;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/page.dart';
import 'package:dartdoc_viewer/readYaml.dart';

/**
 * A group of items that is functionally distinct from any other Category.
 * 
 * The [Category] class will have all the details about the category, 
 * such as comment descriptions or implementation details 
 * like return types and parameter lists. 
 */
@observable
class Category extends Content {
  String name;
  final List<CategoryItem> items = toObservable([]);
  
  Category(this.name, [List<CategoryItem> newItems]) {
    if (newItems != null) {
      items.addAll(newItems);
    }
  }
  
  Category.withMap (this.name, Map<String, String> map) {
    generateContent(map);
  }
  
  /**
   * Adds a item to the list of items. 
   * 
   * [map] can be of type Map<String, String> or String. 
   */
  void addItem(String name, map) {
    if (map is Map) {
      items.add(new CategoryItem(name, new Page.withMap(name, map)));
    } else {
      items.add(new CategoryItem(name));
    }
  }
}

/**
 * A [CategoryItem] is a single item that is distinct from all other items. 
 * 
 * [CategoryItem] include methods, properties, constructors in 
 * classes and libraries.  
 * The [CategoryItem] class will have all the details about the item. 
 * The [Page]s in [CategoryItem] are the pages it will change 
 * to when an item is clicked. 
 */
@observable
class CategoryItem {
  String name;
  Page page;
  
  CategoryItem(this.name, [Page page]) {
    if (page == null) {
      this.page = new Page(this.name);
    } else {
      this.page = page;
    }
  }
}
