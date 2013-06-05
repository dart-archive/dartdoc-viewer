library item;

import 'package:web_ui/web_ui.dart';

/**
 * An item belongs to a category group. 
 * 
 * Items include methods, properties, constructors in classes and libraries.  
 * The Item class will have all the details about the item. 
 */
@observable
class CategoryItem {
  
  String name;
  
  CategoryItem(this.name);
}