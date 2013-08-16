library read_yaml;

import 'dart:async';
import 'dart:html';
import 'dart:json';
import 'package:yaml/yaml.dart';
import 'package:dartdoc_viewer/item.dart';

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
  var doc = parse(response);
  if (doc == null) return null;
  return new Library(doc); 
}