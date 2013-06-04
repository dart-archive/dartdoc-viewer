library item;

import 'package:web_ui/web_ui.dart';

/**
 * Class to represent each item under a section. 
 * 
 * Items include methods, properties, constructors in classes and libraries.  
 * Clicking on an item will provide the user with more details about the item. 
 * The Item class will have all the details about the item. 
 */
@observable
class Item {
  
  String title;
  
  Item(this.title);
}