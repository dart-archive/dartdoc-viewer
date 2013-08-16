library read_yaml;

import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/item.dart';
import 'package:yaml/yaml.dart';

import 'dart:async';
import 'dart:html';
import 'dart:json';

/**
 * Retrieves a file at the given [path].
 */
Future<String> retrieveFileContents(String path) {
  return HttpRequest.getString(path);
}

/**
 * Creates a [Library] object from the [response] string of YAML.
 */
Item loadData(String response) {
  var doc = isYaml ? loadYaml(response) : parse(response);
  if (doc == null) return null;
  return new Library(doc); 
}