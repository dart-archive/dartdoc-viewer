library dartdoc_viewer;
/**
 * Dartdoc_viewer creates html documentation based off Yaml files.
 */

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/section.dart';
import 'package:dartdoc_viewer/item.dart';

part 'util.dart';

final List<Category> dummyCategories = toObservable([]);

main() {
  dummyCategories.addAll(fetchDummyCategories());
}