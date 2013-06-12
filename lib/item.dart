library category_item;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/readYaml.dart';

@observable
class CategoryItem {
  List<CategoryItem> content = toObservable([]);
  
  CategoryItem();
  
  CategoryItem.withYaml(yaml) {
    if (yaml is Map) {
      yaml.keys.forEach((k) => 
        content.add(Category._isCategoryKey(k) ? 
          new Category.withYaml(k, yaml[k]) : new Item.withYaml(k, yaml[k])));
    } else if (yaml is List) {
      yaml.forEach((n) => content.add(new Literal(n)));
    } else {
      content.add(new Literal(yaml));
    }
  }
}

/**
 * An item that has a more content under it.
 */
class Item extends CategoryItem {
  String name;
  
  Item.withYaml(String this.name, yaml) : super.withYaml(yaml);
}

/**
 * An item at its lowest level, and have no more layers under it. 
 */
class Literal extends CategoryItem {
  String content;
  
  Literal(String this.content);
}

/**
 * Category is a container for CategoryItems. 
 */
class Category extends CategoryItem {
  String name;
  
  static const List<String> _categoryKey = 
      const ["libraries", "classes", "constructors", 
       "functions", "variables", "comments", "setters",
       "getters", "interfaces", "superclass", 
       "abstract", "methods", "rtype", "parameters",
       "type", "optional", "default", "static", 
       "operators", "final"];
  
  Category.withYaml(String this.name, yaml) : super.withYaml(yaml);
  
  static bool _isCategoryKey(String key) => _categoryKey.contains(key);
}