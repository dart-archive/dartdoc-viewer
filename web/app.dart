library dartdoc_viewer;

/**
 * Dartdoc_viewer creates html documentation based off Yaml files.
 */
import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/category.dart';
import 'package:dartdoc_viewer/page.dart';
import 'package:yaml/yaml.dart';

part 'util.dart';
part 'readYaml.dart';

final List<Page> pageList = toObservable([]);
Map<String, Page> pageIndex = toObservable({});

String get title => currentPage.name;
@observable Page currentPage = new Page("");

main() {
  var path = "../yaml/largeTest.yaml";
  var yaml = getYamlFile(path);
  yaml.then( (response) {
    pageList.addAll(loadData(response));
    currentPage = pageList.first;
  });
}