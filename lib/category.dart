library category;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/page.dart';

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
  
  Category.withItems(this.name, List<CategoryItem> newItems) {
    items.addAll(newItems);
  }
}

/**
 * An item belongs to a category group. 
 * 
 * Items include methods, properties, constructors in classes and libraries.  
 * The Item class will have all the details about the item. 
 */
@observable
class CategoryItem {
  String name;
  Page page;
  
  CategoryItem(this.name) {
    page = new Page(this.name);
  }
  
  CategoryItem.withPage(this.name, this.page);
}