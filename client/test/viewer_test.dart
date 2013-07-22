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
"optional" : "true"
"named" : "true"
"default" : "true"
"type" : "dart.core.String"
"value" : "\\\"test\\\""''';

String variable =
'''"name" : "variable"
"comment" : "<p>This is a test comment</p>"
"final" : "false"
"static" : "false"
"type" : "dart.core.String"''';

String method = 
'''"name" : "getA"
"comment" : ""
"static" : "false"
"return" : "Library.A"
"parameters" :
  "testInt" :
    "name" : "testInt"
    "optional" : "false"
    "named" : "false"
    "default" : "false"
    "type" : "dart.core.int"
    "value" : "null"''';

String clazz =
'''"name" : "A"
"comment" : "<p>This class is used for testing.</p>"
"superclass" : "dart.core.Object"
"implements" :
  - "Library.B"
  - "Library.C"
"variables" :
"methods" : 
  "getters" :
  "setters" :
  "constructors" :
  "operators" :
  "methods" :
    "doAction" :
      "name" : "doAction"
      "comment" : "<p>This is a test comment</p>."
      "static" : "true"
      "return" : "void"
      "parameters" :''';

String library =
'''"name" : "DummyLibrary"
"comment" : "<p>This is a library.</p>"
"variables" :
"functions" :
"classes" :
  "abstract" :
    "A" :
      "name" : "A"
      "comment" : "<p>This is a test class</p>"
      "superclass" : "dart.core.Object"
      "implements" :
        - "Library.A.B"
        - "Library.C.Y"
      "variables" :
      "methods" :
  "class" :
  "error" :
  "typedef" :''';

// A string of YAML with return types that are in scope for testing links.
String dependencies = 
'''"name" : "Library"
"comment" : "<p>This is a library.</p>"
"variables" :
  "variable" :
    "name" : "variable"
    "comment" : "<p>This is a test comment</p>"
    "final" : "false"
    "static" : "false"
    "type" : "Library.A"
"functions" :
  "setters" :
  "getters" :
  "constructors" :
  "operators" :
  "methods" :
    "changeA" :
      "name" : "changeA"
      "comment" : ""
      "static" : "false"
      "return" : "Library.A"
      "parameters" :
        "testA" :
          "name" : "testA"
          "optional" : "false"
          "named" : "false"
          "default" : "false"
          "type" : "Library.A"
          "value" : "null"
"classes" :
  "class" :
    "A" :
      "name" : "A"
      "comment" : ""
      "superclass" : "dart.core.Object"
      "implements" : 
        - "Library.B"
      "variables" : 
      "methods" :
  "abstract" :
    "B" :
      "name" : "B"
      "comment" : ""
      "superclass" : "dart.core.Object"
      "implements" : 
      "variables" : 
      "methods" :
    "C" :
      "name" : "C"
      "comment" : ""
      "superclass" : "Library.A"
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
    var item = new Variable(yaml['name'], yaml['comment'], 
        yaml['final'] == 'true', yaml['static'] == 'true', yaml['type']);
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
    
    expect(item.variables is Category, isTrue);
    expect(item.operators is Category, isTrue);
    expect(item.constructs is Category, isTrue);
    expect(item.functions is Category, isTrue);
    
    var functions = item.functions;
    expect(functions.content.first is Method, isTrue);
    
    var method = functions.content.first;
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
    
    expect(itemManual.classes is Category, isTrue);
    expect(itemManual.abstractClasses is Category, isTrue);
    expect(itemManual.errors is Category, isTrue);
    expect(itemManual.variables is Category, isTrue);
    expect(itemManual.functions is Category, isTrue);
    expect(itemManual.operators is Category, isTrue);

    var clazz = itemManual.abstractClasses.content.first;
    expect(clazz is Class, isTrue);
    
    var implements = clazz.implements;
    implements.forEach((element) => expect(element is LinkableType, isTrue));
  });
  
  // Test that links that are in scope are aliased to the correct objects.
  test('dependencies_test', () {
    var currentMap = loadYaml(dependencies);
    var library = new Library(currentMap);
    buildHierarchy(library, library);
    
    var classes = library.classes;
    var abstractClasses = library.abstractClasses;
    var variables = library.variables;
    var functions = library.functions;
    
    var variable = variables.content.first;
    var classA = classes.content.first;
    var classB, classC;
    abstractClasses.content.forEach((element) {
      if (element.name == 'B') classB = element;
      if (element.name == 'C') classC = element;
    });
    var function = functions.content.first;
    
    // TODO(tmandel): Since LinkableType.location does not return an Item
    // anymore, this test can't run without instantiating a viewer and 
    // attempting to change the homepage. This should be fixed when a global
    // map from qualified name to Item is used instead of the logic in
    // handleLink in web/app.dart. Add checks that the return types and
    // superclasses are aliased to the right classes when this is done.
  });
}