// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library viewer_test;

import 'dart:html';

import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/read_yaml.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:unittest/unittest.dart';
import 'package:yaml/yaml.dart';

// Since YAML is sensitive to whitespace, these are declared in the top-level
// for readability and to avoid possible parsing errors.
String empty = '';

// The 'value' field is escaped more than normal to
// account for the use of literal strings.
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

// A string of YAML with return types that are in scope for testing links.
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
    "methods" :
  "C" :
    "name" : "C"
    "qualifiedname" : "Library.C"
    "comment" : ""
    "superclass" : "Library.A"
    "abstract" : "false"
    "typedef" : "false"
    "implements" : 
    "variables" : 
    "methods" :''';

void main() {
  useHtmlEnhancedConfiguration();
    
  test('read_empty', () {
    // Check that read_yaml reads the right data.
    retrieveFileContents('yaml/empty.yaml').then(expectAsync1((data) {
      expect(data, equals(empty));
      // Test that reading in an empty file doesn't throw an exception.
      expect(() => loadData(data), returnsNormally);
    }));
  });
  
  test('parameter_test', () {
    // Check that read_yaml reads the right data.
    retrieveFileContents('yaml/parameter.yaml').then(expectAsync1((data) {
      expect(data, equals(parameter));
    }));
    
    var currentMap = loadYaml(parameter);
    var item = new Parameter(currentMap['name'], currentMap);
    expect(item is Parameter, isTrue);
    expect(item.type is LinkableType, isTrue);
  });
  
  test('variable_test', () {
    // Check that read_yaml reads the right data.
    retrieveFileContents('yaml/variable.yaml').then(expectAsync1((data) {
      expect(data, equals(variable));
    }));
  
    var yaml = loadYaml(variable);
    var item = new Variable(yaml);
    expect(item is Variable, isTrue);
    expect(item.type is LinkableType, isTrue);
  });
  
  test('clazz_test', () {
    // Check that read_yaml reads the right data.
    retrieveFileContents('yaml/class.yaml').then(expectAsync1((data) {
      expect(data, equals(clazz));
    }));
    
    var yaml = loadYaml(clazz);
    var item = new Class(yaml);
    expect(item is Class, isTrue);
    
    expect(item.content.first is Category, isTrue);
    
    var category = item.content.first;
    expect(category.content.first is Method, isTrue);
    
    var method = category.content.first;
    expect(method.type is LinkableType, isTrue);
    
    var implements = item.implements;
    expect(implements is List, isTrue);
    implements.forEach((interface) => 
        expect(interface is LinkableType, isTrue));
    
    var superClass = item.superClass;
    expect(superClass is LinkableType, isTrue);
  });
  
  test('method_test', () {
    // Check that read_yaml reads the right data.
    retrieveFileContents('yaml/method.yaml').then(expectAsync1((data) {
      expect(data, equals(method));
    }));
  
    var yaml = loadYaml(method);
    var item = new Method(yaml);
    expect(item is Method, isTrue);
        
    expect(item.type is LinkableType, isTrue);
    expect(item.parameters is List, isTrue);
    expect(item.parameters.first is Parameter, isTrue);
    expect(item.parameters.first.type is LinkableType, isTrue);
  });
  
  test('library_test', () {
    // Check that read_yaml reads the right data.
    retrieveFileContents('yaml/library.yaml').then(expectAsync1((data) {
      expect(data, equals(library));
    }));
  
    var yaml = loadYaml(library);
    // Manually instantiated Library object from yaml.
    var itemManual = new Library(yaml);
    expect(itemManual is Library, isTrue);
    
    // Automatically instantiated Library object from loadData in read_yaml.
    var itemAutomatic = loadData(library);
    expect(itemAutomatic is Library, isTrue);
    
    // Test that the same results are produced.
    expect(itemAutomatic.name, equals(itemManual.name));
    expect(itemAutomatic.comment, equals(itemManual.comment));
    // TODO(tmandel): Should test for the same classes/functions/etc.
    
    expect(itemManual.content.first is Category, isTrue);
    
    var category = itemManual.content.first;
    var clazz = category.content.first;
    expect(clazz is Class, isTrue);
    
    var implements = clazz.implements;
    implements.forEach((element) => expect(element is LinkableType, isTrue));
  });
  
  // Test that links that are in scope are aliased to the correct objects.
  test('dependencies_test', () {
    var currentMap = loadYaml(dependencies);
    var library = new Library(currentMap);
    buildHierarchy(library, library);
    
    var variables, classes, functions;
    library.content.forEach((category) {
      if (category.name == 'Classes') classes = category;
      if (category.name == 'Variables') variables = category;
      if (category.name == 'Functions') functions = category;
    });
    var variable = variables.content.first;
    var classA, classB, classC;
    classes.content.forEach((element) {
      if (element.name == 'A') classA = element;
      if (element.name == 'B') classB = element;
      if (element.name == 'C') classC = element;
    });
    var function = functions.content.first;
    
    // Test that the destination of the links are aliased with classA.
    expect(variable.type.location, equals(classA));
    expect(function.type.location, equals(classA));
    
    var parameter = function.parameters.first;
    expect(parameter.type.location, equals(classA));
    
    var implements = classA.implements.first;
    expect(implements.location, equals(classB));
    
    var superClass = classC.superClass;
    expect(superClass.location, equals(classA));
  });
}