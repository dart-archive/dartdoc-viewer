library read_yaml;

import 'dart:async';
import 'dart:html';
import 'package:yaml/yaml.dart';
import 'package:dartdoc_viewer/item.dart';

/**
 *  Used to read a YAML file and generate a page. 
 *  
 *  Recursively goes through the YAML file to 
 *  find all the pages, categories and items. 
 */
Future<String> getYamlFile(String path) {
  return HttpRequest.getString(path);
}

Item loadData(String response) {
  var doc = loadYaml(response);
  return new Item.fromYaml(doc['name'], doc); 
}
