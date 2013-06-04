library section;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/item.dart';

/**
 * Class to represent each section in the doc. 
 * 
 * Sections are categories for separating the items in a class or library. 
 * Examples of sections include constructors, properties or methods. 
 * Each section will have a list of items under it. 
 * The section class will have all the details about the section. 
 */
@observable
class Section {
  
  String title;
  final List<Item> items = toObservable([]);
  
  Section(this.title, List<Item> newItems) {
    items.addAll(newItems);
  }
}