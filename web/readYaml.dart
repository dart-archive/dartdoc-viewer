part of dartdoc_viewer;

/**
 *  Used to read a YAML file and generate a page. 
 *  
 *  Recursively goes through the YAML file to 
 *  find all the pages, categories and items. 
 */

Future getYamlFile(path) {
  return HttpRequest.getString(path);
}

List<Page> loadData(response) {
  var doc = loadYaml(response);
  List<Page> pageList = new List<Page>();
  for (String k in doc.keys) {
    Page page = generatePage(k, doc[k]);
    pageList.add(page);
  }
  return pageList;
}

/**
 *  Returns a page with a list of categories from a map of category. 
 */
Page generatePage(String name, Map<String, String> pageMap) {
  List<Category> categories = new List<Category>();
  for (String k in pageMap.keys) {
    Category category;
    // To check whether there is another map contained inside. 
    // If there is another map, it is necessary to generate a list of items. 
    if (pageMap[k].toString()[0] == '{') {
      category = generateCategory(k, pageMap[k]);
    } else {
      category = new Category(k);
    }
    categories.add(category);
  }
  Page page = new Page.withCategories(name, categories);
  pageIndex[name] = page;
  return page;
}

/**
 *  Returns a category with a list of items from a map of items. 
 */
Category generateCategory(String name, Map<String, String> categoryMap) {
  List<CategoryItem> items = new List<CategoryItem>();
  for (String k in categoryMap.keys) {
    CategoryItem item;
    // To check whether there is another map contained inside. 
    // If there is another map, it is necessary to generate another page. 
    if (categoryMap[k].toString()[0] == '{') {
      item = new CategoryItem.withPage(k, generatePage(k, categoryMap[k]));
    } else {
      item = new CategoryItem(k);
    }
    items.add(item);
  }
  Category category = new Category.withItems(name, items);
  return category;
}