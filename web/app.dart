library dartdoc_viewer;

/**
 * Dartdoc_viewer creates html documentation based off Yaml files.
 */
import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/category.dart';
import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/page.dart';
import 'package:yaml/yaml.dart';

part 'util.dart';
part 'readYaml.dart';

final List<Category> dummyCategories = toObservable([]);
final List<Category> testYaml = toObservable([]);

Map<String, String> testMap = toObservable({});

String get title => page.name;

@observable Page page = new Page("");

main() {
  var path = "../yaml/largeTest.yaml";
  var yaml = getYamlFile(path);
  yaml.then( (response) {
    page = loadData(response);
  });
}