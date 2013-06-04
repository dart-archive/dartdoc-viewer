library dartdoc_viewer;

import 'dart:html';
import 'package:web_ui/web_ui.dart';

import 'package:dartdoc_viewer/item.dart';

/**
 * Function to create some dummy method data.
 */
List<Item> fetchDummyMethods() {
  List<Item> methods = new List<Item>();
  methods.add(new Item("Directory"));
  methods.add(new Item("File"));
  methods.add(new Item("Options"));
  methods.add(new Item("Path"));
  methods.add(new Item("SecureSocket"));
  
  return methods;
}

void printItemName(Item item) {
  print(item.title);
}

final List<Item> dummyMethods = toObservable([]);

main() {
 dummyMethods.addAll(fetchDummyMethods()); 
}