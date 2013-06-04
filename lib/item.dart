library item;

import 'package:web_ui/web_ui.dart';

@observable
class Item {
  
  String _title;
  
  String get title => _title;
  
  Item(this._title);
}