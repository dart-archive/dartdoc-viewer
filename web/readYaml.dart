part of dartdoc_viewer;

Future getHttp() {
  String path = "../yaml/largeTest.yaml";
  
  return HttpRequest.getString(path);
}

Page loadData(response) {
  var doc = loadYaml(response);
  print(doc);
  
  //List<Category> sections = new List<Category>();
  for (String k in doc.keys) {
    print(k);
    print(doc[k]);
    
    page = generatePage(k, doc[k]);
    
    return page;
  }
}

Page generatePage(String name, Map<String, String> pageMap) {
  
  print("In generatePage for $name");
  
  List<Category> categories = new List<Category>();
  for (String k in pageMap.keys) {
    print(k);
    print(pageMap[k]);
    
    Category category;
    
    if (pageMap[k].toString().contains(": {")) {
      category = generateCategory(k, pageMap[k]);
    } else {
      category = new Category(k);
    }
    
    categories.add(category);
  }
  
  Page page = new Page.withCategoriesList(name, categories);
  
  return page;
}

Category generateCategory(String name, Map<String, String> categoryMap) {
  
  print("In generateCategory for $name");
  
  List<CategoryItem> items = new List<CategoryItem>();
  for (String k in categoryMap.keys) {
    print(k);
    print(categoryMap[k]);
    
    CategoryItem item;
    // To check whether there is another map contained inside. 
    // If there is another map, it is necessary to generate another page. 
    if (categoryMap[k].toString().contains(": {")) {
      item = new CategoryItem.withPage(k, generatePage(k, categoryMap[k]));
    } else {
      item = new CategoryItem(k);
    }
    items.add(item);
  }
  
  Category category = new Category.withItemList(name, items);
  
  return category;
}