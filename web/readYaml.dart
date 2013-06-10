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
    //Page page = generatePage(k, doc[k]);
    Page page = generateContent(k, doc[k], true);
    pageList.add(page);
  }
  return pageList;
}

/**
 * Returns either a Page or Category depending on what is needed. 
 * 
 * needPage should be true if a page is needed, 
 * and false if a category is needed. 
 */
generateContent(String name, Map<String, String> map, bool needPage) {
  List subContentList = new List();
  for(var k in map.keys){
    var subContent;
    if (map[k] is Map) {
      if (needPage) {
        subContent = generateContent(k, map[k], false);
      } else {
        subContent = new CategoryItem.withPage(k, 
            generateContent(k, map[k], true));
      }
    } else {
      if (needPage) {
        subContent = new Category(k);
      } else {
        subContent = new CategoryItem(k);
      }
    }
    subContentList.add(subContent);
  }
  var content;
  if (needPage) {
    content = new Page.withCategories(name, subContentList);
    pageIndex[name] = content;
  } else {
    content = new Category.withItems(name, subContentList);
  }
  return content;
}