library dummy_content;

import 'package:dartdoc_viewer/category.dart';

/**
 * Returns some dummy method data.
 */
List<CategoryItem> fetchDummyMethods() => 
  [new CategoryItem("Directory"),
   new CategoryItem("File"),
   new CategoryItem("Options"),
   new CategoryItem("Path"),
   new CategoryItem("SecureSocket")];
    
/**
 * Returns some dummy Category data.  
 */
List<Category> fetchDummyCategories() =>
  [new Category("Constructors", [new CategoryItem("factory File(String path)"),
  new CategoryItem("factory File.fromPath(Path path)")]),
  new Category("Properties",[new CategoryItem("final Directory directory"),
  new CategoryItem("final String path")]),
  new Category("Methods", fetchDummyMethods())];
