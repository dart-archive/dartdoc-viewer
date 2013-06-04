library item;

import 'package:web_ui/web_ui.dart';

/**
 * Class to represent each clickable item under a section. 
 * Clicking on an item will provide the user with more details about the item. 
 * The Item class will have all the details about the item. 
 */
@observable
class Item {
  
  String _title;
  
  String get title => _title;
  
  Item(this._title);
}