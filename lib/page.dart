library page;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/category.dart';

/**
 * A single page in the documentation. 
 * 
 * The list of categories will separate the items on the page. 
 */
@observable 
class Page {
  String name;
  final List<Category> categories = toObservable([]);
  
  Page(this.name, [List<Category> newCategories]) {
    if (newCategories != null) {
      categories.addAll(newCategories);
    }
  }
}
