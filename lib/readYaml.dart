library read_yaml;

import 'dart:async';
import 'dart:html';
import 'package:yaml/yaml.dart';
import 'package:dartdoc_viewer/page.dart';

/**
 *  Used to read a YAML file and generate a page. 
 *  
 *  Recursively goes through the YAML file to 
 *  find all the pages, categories and items. 
 */
Future<String> getYamlFile(path) {
  return HttpRequest.getString(path);
}

Iterable<Page> loadData(String response) {
  var doc = loadYaml(response);
  return doc.keys.map((String k) => new Page.withMap(k, doc[k])); 
}

/**
 * [Content] is the details of an object.
 * 
 * [generateContent] recursively adds the details to the object. 
 */
abstract class Content {
  Object generateContent(String name, Map<String, String> map) {
    for (var k in map.keys) {
      addItems(k, map[k]);
    }
  }
  
  /**
   * Adds content to the list of subContents. 
   * 
   * [map] can be of type Map<String, String> or String. 
   */
  void addItems(String name, map);
}
