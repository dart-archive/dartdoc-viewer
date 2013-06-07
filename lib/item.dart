library item;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/page.dart';

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