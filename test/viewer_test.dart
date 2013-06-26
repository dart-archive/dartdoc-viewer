// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library viewer_test;

import 'dart:html';

import '../web/app.dart' as app;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:yaml/yaml.dart';
import 'package:dartdoc_viewer/read_yaml.dart';
import 'package:dartdoc_viewer/item.dart';

// Since YAML is sensitive to whitespace, these are declared in the top-level
// to avoid possible parsing errors.
String empty = '';

String parameter =
'''"name" : "input"
"qualifiedname" : "Library.method#input"
"optional" : "true"
"named" : "true"
"default" : "true"
"type" : "dart.core.String"
"value" : "\\\"test\\\""''';

String variable =
'''"name" : "variable"
"qualifiedname" : "Library.variable"
"comment" : "<p>This is a test comment</p>"
"final" : "false"
"static" : "false"
"type" : "dart.core.String"''';

String method = 
'''"name" : "getA"
"qualifiedname" : "Library.B.getA"
"comment" : ""
"type" : "method"
"static" : "false"
"return" : "Library.A"
"parameters" :
  "testInt" :
    "name" : "testInt"
    "qualifiedname" : "Library.B.getA#testInt"
    "optional" : "false"
    "named" : "false"
    "default" : "false"
    "type" : "dart.core.int"
    "value" : "null"''';

String clazz =
'''"name" : "A"
"qualifiedname" : "Library.A"
"comment" : "<p>This class is used for testing.</p>"
"superclass" : "dart.core.Object"
"abstract" : "false"
"typedef" : "false"
"implements" :
  - "Library.B"
  - "Library.C"
"variables" :
"methods" : 
  "doAction" :
    "name" : "doAction"
    "qualifiedname" : "Library.A.doAction"
    "comment" : "<p>This is a test comment</p>."
    "type" : "method"
    "static" : "true"
    "return" : "void"
    "parameters" :''';

String library =
'''"name" : "DummyLibrary"
"qualifiedname" : "DummyLibrary"
"comment" : "<p>This is a library.</p>"
"variables" :
"functions" :
"classes" :
  "A" :
    "name" : "A"
    "qualifiedname" : "DummyLibrary.A"
    "comment" : "<p>This is a test class</p>"
    "superclass" : "dart.core.Object"
    "abstract" : "true"
    "typedef" : "false"
    "implements" :
      - "Library.A.B"
      - "Library.C.Y"
    "variables" :
    "methods" :''';

String dependencies = 
'''"name" : "Library"
"qualifiedname" : "Library"
"comment" : "<p>This is a library.</p>"
"variables" :
  "variable" :
    "name" : "variable"
    "qualifiedname" : "Library.variable"
    "comment" : "<p>This is a test comment</p>"
    "final" : "false"
    "static" : "false"
    "type" : "Library.A"
"functions" :
  "changeA" :
    "name" : "changeA"
    "qualifiedname" : "Library.A.changeA"
    "comment" : ""
    "type" : "method"
    "static" : "false"
    "return" : "Library.A"
    "parameters" :
      "testA" :
        "name" : "testA"
        "qualifiedname" : "Library.A.changeA#testInt"
        "optional" : "false"
        "named" : "false"
        "default" : "false"
        "type" : "Library.A"
        "value" : "null"
"classes" :
  "A" :
    "name" : "A"
    "qualifiedname" : "Library.A"
    "comment" : ""
    "superclass" : "dart.core.Object"
    "abstract" : "false"
    "typedef" : "false"
    "implements" : 
      - "Library.B"
    "variables" : 
    "methods" :
  "B" :
    "name" : "B"
    "qualifiedname" : "Library.B"
    "comment" : ""
    "superclass" : "dart.core.Object"
    "abstract" : "true"
    "typedef" : "false"
    "implements" : 
    "variables" : 
    "methods" :''';
    

// TODO(tmandel): After multiple libraries are included, test with ambiguous 
// qualified names if applicable.
// TODO(tmandel): Change type tests to be more specific once Class, Library,
// Variable, etc. objects are included.
void main() {
  useHtmlEnhancedConfiguration();
  
  group('empty_tests', () {
    
    test('read_empty', () {
      getYamlFile('yaml/empty.yaml').then(expectAsync1((data) {
        expect(data, equals(empty));
      }));
    });
    
    test('empty_is_null', () {
      var currentMap = loadYaml(empty);
      expect(currentMap, isNull);
    });
  });
  
  group('parameter_tests', () {
    
    test('read_parameter', () {
      getYamlFile('yaml/parameter.yaml').then(expectAsync1((data) {
        expect(data, equals(parameter));
      }));
    });
    
    test('loads_normally', () {
      expect(() => loadYaml(parameter), returnsNormally);
      var currentMap = loadYaml(parameter);
      expect(currentMap, isNotNull);
    });
    
    test('create_instance', () {
      var currentMap = loadYaml(parameter);
      var item = new Parameter(currentMap['name'], currentMap);
      expect(item is Parameter, isTrue);
    });
    
    test('inner_types', () {
      var currentMap = loadYaml(parameter);
      var item = new Parameter(currentMap['name'], currentMap);
          
      expect(item.type is LinkableType, isTrue);
    });
  });
  
  group('variable_tests', () {
    
    test('read_variable', () {
      getYamlFile('yaml/variable.yaml').then(expectAsync1((data) {
        expect(data, equals(variable));
      }));
    });
    
    test('loads_normally', () {
      expect(() => loadYaml(variable), returnsNormally);
    });
    
    test('create_instance', () {
      var yaml = loadYaml(variable);
      var item = new Variable(yaml);
      expect(item is Variable, isTrue);
    });
    
    test('inner_types', () {
      var yaml = loadYaml(variable);
      var item = new Variable(yaml);
      expect(item.type is LinkableType, isTrue);
    });
  });

  group('class_tests', () {
    
    test('read_class', () {
      getYamlFile('yaml/class.yaml').then(expectAsync1((data) {
        expect(data, equals(clazz));
      }));
    });
    
    test('loads_normally', () {
      expect(() => loadYaml(clazz), returnsNormally);
    });
    
    test('create_instance', () {
      var yaml = loadYaml(clazz);
      var item = new Class(yaml);
      expect(item is Class, isTrue);
    });
    
    test('inner_types', () {
      var yaml = loadYaml(clazz);
      var item = new Class(yaml);
      
      expect(item.content.length, equals(1));
      expect(item.content.first is Category, isTrue);
      
      var category = item.content.first;
      expect(category.content.length, equals(1));
      expect(category.content.first is Method, isTrue);
      
      var method = category.content.first;
      expect(method.type is LinkableType, isTrue);
      
      // TODO(tmandel): Test 'implements' when I implement it...
    });
  });
  
  group('method_tests', () {
    
    test('read_method', () {
      getYamlFile('yaml/method.yaml').then(expectAsync1((data) {
        expect(data, equals(method));
      }));
    });
    
    test('loads_normally', () {
      expect(() => loadYaml(method), returnsNormally);
    });
    
    test('create_instance', () {
      var yaml = loadYaml(method);
      var item = new Method(yaml);
      expect(item is Method, isTrue);
    });
    
    test('inner_types', () {
      var yaml = loadYaml(method);
      var item = new Method(yaml);
          
      expect(item.type is LinkableType, isTrue);
      expect(item.parameters is List, isTrue);
      expect(item.parameters.first is Parameter, isTrue);
      expect(item.parameters.first.type is LinkableType, isTrue);
    });
  });
  
  group('library_tests', () {
    
    test('read_library', () {
      getYamlFile('yaml/library.yaml').then(expectAsync1((data) {
        expect(data, equals(library));
      }));
    });
    
    test('loads_normally', () {
      expect(() => loadData(library), returnsNormally);
    });
    
    test('create_instance', () {
      var yaml = loadYaml(library);
      var item = new Library(yaml);
      expect(item is Library, isTrue);
    });
    
    test('loadData', () {
      var yaml = loadYaml(library);
      var item = new Library(yaml);
      var item2 = loadData(library);
      expect(item2 is Library, isTrue);
      expect(item2.name, equals(item.name));
      expect(item2.comment, equals(item.comment));
    });
    
    test('inner_types', () {
      var yaml = loadYaml(library);
      var item = new Library(yaml);
      
      expect(item.content.length, equals(1));
      expect(item.content.first is Category, isTrue);
      
      var category = item.content.first;
      var classA = category.content.first;
      expect(classA is Class, isTrue);
      
      var implements = classA.implements;
      implements.forEach((element) => expect(element is LinkableType, isTrue));
    });
  });
  
  group('link_tests', () {
    
    test('loads_normally', () {
      expect(() => loadYaml(dependencies), returnsNormally);
    });
    
    test('dependencies_links', () {
      var currentMap = loadYaml(dependencies);
      var library = new Library(currentMap);
      app.buildHierarchy(library, library);
      
      var variables, classes, functions;
      library.content.forEach((category) {
        if (category.name == 'Classes') classes = category;
        if (category.name == 'Variables') variables = category;
        if (category.name == 'Functions') functions = category;
      });
      var variable = variables.content.first;
      var classA, classB;
      classes.content.forEach((element) {
        if (element.name == "A") classA = element;
        if (element.name == "B") classB = element;
      });
      var function = functions.content.first;
      
      expect(variable.type.location, equals(classA));
      expect(function.type.location, equals(classA));
      
      var parameters = function.parameters;
      var parameter = parameters.first;
      
      expect(parameter.type.location, equals(classA));
      
      var implements = classA.implements.first;
      expect(implements.location, equals(classB));
    });
  });
}