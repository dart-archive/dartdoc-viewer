library category;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/item.dart';

/**
 * A category belongs to a class or library page. 
 * 
 * Categories separate items in a class or library. 
 * Examples of categories include constructors, properties or methods. 
 * Each categories will have a list of items under it. 
 * The Category class will have all the details about the category. 
 */
@observable
class Category {
  
  String name;
  final List<CategoryItem> items = toObservable([]);
  
  Category(this.name);
  
  Category.withItemList(this.name, List<CategoryItem> newItems) {
    items.addAll(newItems);
  }
}