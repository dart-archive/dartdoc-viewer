part of dartdoc_viewer;

/**
 * Function to create some dummy method data.
 */
List<CategoryItem> fetchDummyMethods() => [new CategoryItem("Directory"),
   new CategoryItem("File"),
   new CategoryItem("Options"),
   new CategoryItem("Path"),
   new CategoryItem("SecureSocket")];
  
/**
 * Function to create some dummy Category data.  
 */
List<Category> fetchDummyCategories() {
  List<CategoryItem> constructors = 
      [new CategoryItem("factory File(String path)"),
       new CategoryItem("factory File.fromPath(Path path)")];
  
  List<CategoryItem> properties = 
      [new CategoryItem("final Directory directory"),
       new CategoryItem("final String path")];
  
  List<CategoryItem> methods = fetchDummyMethods();
  
  List<Category> categories = [new Category.withItems("Constructors", constructors),
                               new Category.withItems("Properties", properties),
                               new Category.withItems("Methods", methods)];
  return categories;
}