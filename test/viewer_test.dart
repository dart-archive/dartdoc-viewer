// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library viewer_test;

import 'dart:html';

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:yaml/yaml.dart';
import 'package:dartdoc_viewer/read_yaml.dart';
import 'package:dartdoc_viewer/item.dart';

// Since YAML is sensitive to whitespace, these are declared in the top-level
// to avoid possible parsing errors.
String empty = '';

String variable =
'''"name" : "variable"
"qualifiedname" : "Library.variable"
"comment" : "<p>This is a test comment</p>"
"final" : "false"
"static" : "false"
"type" : "dart.core.String"''';

String parameter =
'''"name" : "input"
"qualifiedname" : "Library.method#input"
"optional" : "true"
"named" : "true"
"default" : "true"
"type" : "dart.core.String"
"value" : "\"test\""''';

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
    "variables" :
    "methods" :''';

// TODO(tmandel): After multiple libraries are included, test with ambiguous 
// qualified names if applicable.
// TODO(tmandel): Change type tests to be more specific once Class, Library,
// Variable, etc. objects are included.
void main() {
  useHtmlEnhancedConfiguration();
  
  group('empty_tests', () {
    
    test('empty_is_null', () {
      expect(() => loadData(empty), returnsNormally);
      var item = loadData(empty);
      expect(item, isNull);
    });
  });
  
  group('parameter_tests', () {
    
    test('loads_normally', () {
      expect(() => loadData(parameter), returnsNormally);
    });
    
    test('create_instance', () {
      var yaml = loadYaml(parameter);
      var item = new Parameter(yaml['name'], yaml);
      expect(item is Parameter, isTrue);
    });
    
    test('inner_types', () {
      var yaml = loadYaml(parameter);
      var item = new Parameter(yaml['name'], yaml);
          
      expect(item.type is LinkableType, isTrue);
    });
  });
  
  
  group('variable_tests', () {
    
    test('loads_normally', () {
      expect(() => loadData(variable), returnsNormally);
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
    
    test('loads_normally', () {
      expect(() => loadData(clazz), returnsNormally);
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
    
    test('loads_normally', () {
      expect(() => loadData(method), returnsNormally);
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
    
    test('loads_normally', () {
      expect(() => loadData(library), returnsNormally);
    });
    
    test('create_instance', () {
      var yaml = loadYaml(library);
      var item = new Library(yaml);
      expect(item is Library, isTrue);
    });
    
    test('inner_types', () {
      var yaml = loadYaml(library);
      var item = new Library(yaml);
      
      expect(item.content.length, equals(1));
      expect(item.content.first is Category, isTrue);
      
      var category = item.content.first;
      expect(category.content.length, equals(1));
      expect(category.content.first is Class, isTrue);
      
      // TODO(tmandel): Test 'implements' when I implement it...
    });
  });
}