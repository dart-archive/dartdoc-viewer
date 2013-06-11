library page;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/category.dart';
import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/readYaml.dart';

/**
 * A single page in the documentation. 
 * 
 * The list of categories will separate the items on the page. 
 */
@observable 
class Page extends Content {
  String name;
  final List<Category> categories = toObservable([]);
  
  Page(this.name, [List<Category> newCategories]) {
    if (newCategories != null) {
      categories.addAll(newCategories);
    }
  }
  
  Page.withMap(this.name, Map<String, String> map) {
    generateContent(map);
  }
  
  /**
   * Adds a category to the list of categories. 
   * 
   * [map] can be of type Map<String, String> or String. 
   */
  void addItem(String name, map) {
    if (map is Map) {
      categories.add(new Category.withMap(name, map));
    } else {
      categories.add(new Category(name));
    }
  }
}
