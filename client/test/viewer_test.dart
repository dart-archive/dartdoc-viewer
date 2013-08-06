// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library viewer_test;

import 'dart:html';

import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/read_yaml.dart';
import 'package:dartdoc_viewer/search.dart';
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
"type" : 
  - "inner" :
    "outer" : "dart.core.String"
"value" : "\\\"test\\\""
"annotations" :''';

String variable =
'''"name" : "variable"
"qualifiedName" : "Library.variable"
"comment" : "<p>This is a test comment</p>"
"final" : "false"
"static" : "false"
"constant" : "false"
"type" : 
  - "inner" :
    "outer" : "dart.core.String"
"annotations" :''';

String generic_one_level_variable =
'''"name" : "generic"
"qualifiedname" : "Library.generic"
"comment" : "<p>This is a test comment for generic types</p>"
"final" : "false"
"static" : "false"
"constant" : "false"
"type" : 
  - "inner" : 
      - "inner" :
        "outer" : "dart.core.String"
    "outer" : "dart.core.List"
"annotations" :''';

String generic_two_level_variable =
'''"name" : "generic"
"qualifiedname" : "Library.generic"
"comment" : "<p>This is a test comment for generic types</p>"
"final" : "false"
"static" : "false"
"constant" : "false"
"type" : 
  - "inner" : 
      - "inner" :
          - "inner" :
            "outer" : "dart.core.int"
          - "inner" :
            "outer" : "dart.core.String" 
        "outer" : "dart.core.Map"
    "outer" : "dart.core.List"
"annotations" :''';

String setter =
'''"abstract" : "false"
"annotations" :
"comment" : "<p>This is a setter</p>"
"commentfrom" : ""
"constant" : "false"
"name" : "length="
"parameters" :
  "newLength" :
    "annotations" :
    "default" : "false"
    "name" : "newLength"
    "named" : "false"
    "optional" : "false"
    "type" :
      - "inner" : 
        "outer" : "dart.core.int"
    "value" : "null"
"qualifiedname" : "Library.Class.length="
"return" : 
  - "inner" :
    "outer" : "void"
"static" : "false"''';

String method = 
'''"name" : "getA"
"qualifiedName" : "Library.getA"
"comment" : ""
"static" : "false"
"constant" : "false"
"abstract" : "false"
"annotations" : 
"return" : 
  - "inner" : 
    "outer" : "Library.A"
"parameters" :
  "testInt" :
    "name" : "testInt"
    "optional" : "false"
    "named" : "false"
    "default" : "false"
    "type" : 
      - "inner" : 
        "outer" : "dart.core.int"
    "value" : "null"
    "annotations" :''';

String clazz =
'''"name" : "A"
"qualifiedName" : "Library.A"
"comment" : "<p>This class is used for testing.</p>"
"isAbstract" : "false"
"superclass" : "dart.core.Object"
"implements" :
  - "Library.B"
  - "Library.C"
"variables" :
"annotations" : 
"generics" :
"methods" : 
  "getters" :
  "setters" :
  "constructors" :
    "" :
      "abstract" : "false"
      "annotations" : 
      "comment" :
      "commentfrom" : ""
      "constant" : "false"
      "name" : ""
      "parameters" :
      "qualifiedname" : "Library.A."
      "return" :
        - "inner" :
          "outer" : "Library.A"
      "static" : "false"
  "operators" :
  "methods" :
    "doAction" :
      "name" : "doAction"
      "qualifiedName" : "Library.A.doAction"
      "comment" : "<p>This is a test comment</p>."
      "static" : "true"
      "constant" : "false"
      "abstract" : "false"
      "annotations" :
      "return" : 
        - "inner" :
          "outer" : "void"
      "parameters" :''';

String library =
'''"name" : "Library"
"qualifiedName" : "Library"
"comment" : "<p>This is a library.</p>"
"variables" :
"functions" :
"annotations" :
"classes" :
  "class" :
    - "name" : "Library.A"
      "preview" : "<p>This is a preview comment</p>"
  "error" :
  "typedef" :''';

// A string of YAML with return types that are in scope for testing links.
String dependencies = 
'''"name" : "Library"
"qualifiedName" : "Library"
"annotations" :
"comment" : "<p>This is a library.</p>"
"variables" :
  "variable" :
    "name" : "variable"
    "qualifiedName" : "Library.variable"
    "comment" : "<p>This is a test comment</p>"
    "final" : "false"
    "static" : "false"
    "constant" : "false"
    "type" : 
      - "inner" :
        "outer" : "Library.A"
    "annotations" :
"functions" :
  "setters" :
  "getters" :
  "constructors" :
  "operators" :
  "methods" :
    "changeA" :
      "name" : "changeA"
      "qualifiedName" : "Library.changeA"
      "comment" : ""
      "constant" : "false"
      "static" : "false"
      "abstract" : "false"
      "return" : 
        - "inner" : 
          "outer" : "Library.A"
      "parameters" :
        "testA" :
          "name" : "testA"
          "annotations" :
          "optional" : "false"
          "named" : "false"
          "default" : "false"
          "type" : 
            - "inner" :
              "outer" : "Library.A"
          "value" : "null"
      "annotations" : 
"classes" :
  "class" :
    - "name" : "Library.A"
    - "name" : "Library.B"
    - "name" : "Library.C"''';

String annotations =
'''"name" : "Library"
"qualifiedname" : "Library"
"comment" : "<p>This is an annotation test</p>"
"variables" :
  "variable" :
    "name" : "variable"
    "qualifiedname" : "Library.variable"
    "comment" : ""
    "final" : "false"
    "static" : "false"
    "constant" : "false"
    "type" :
      - "inner" :
        "outer" : "Library.A"
    "annotations" :
      - "name" : "Library.B"
        "parameters" :
          - "firstParameter"
          - "secondParameter"
      - "name" : "Library.A"
        "parameters" :
"functions" :
  "setters" :
  "getters" :
  "constructors" :
  "operators" :
  "methods" :
"classes" :
  "class" :
    - "Library.A"
  "abstract" :
    - "Library.B"
  "error" :
  "typedef" :''';

String clazzA =
'''"name" : "A"
"qualifiedName" : "Library.A"
"isAbstract" : "false"
"annotations" : 
"generics" : 
"comment" : ""
"superclass" : "dart.core.Object"
"implements" : 
  - "Library.B"
"variables" : 
"methods" :''';

String clazzB =
'''"name" : "B"
"qualifiedName" : "Library.B"
"annotations" :
"isAbstract" : "true"
"generics" : 
"comment" : ""
"superclass" : "dart.core.Object"
"implements" : 
"variables" : 
"methods" :''';

String clazzC = 
'''"name" : "C"
"qualifiedName" : "Library.C"
"annotations" :
"isAbstract" : "true"
"generics" : 
"comment" : ""
"superclass" : "Library.A"
"implements" : 
"variables" : 
"methods" :''';

String manyLibrariesIndex =
'''dart.core library
dart.core.Object class
dart.core.Object.toString method
dart.core.Object.runtimeType getter
dart.core.Object.hashCode method
dart.core.List class
dart.core.int class
dart.core.String class
dart.core.num class
dart.core.num.isNaN getter
dart.core.num.isNegative getter
dart.collection library
dart.collection.LinkedList class
dart.collection.LinkedList.forEach method
dart.collection.HashSet class
dart.mirrors library
dart.mirrors.Mirror class
dart.dom.svg library
dart.dom.svg.Number class''';

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
    expect(item.name is String, isTrue);
    expect(item.type is NestedType, isTrue);
    expect(item.annotations is List, isTrue);
  });
  
  test('variable_test', () {
    // Check that read_yaml reads the right data.
    retrieveFileContents('yaml/variable.yaml').then(expectAsync1((data) {
      expect(data, equals(variable));
    }));
    
    var yaml = loadYaml(variable);
    var item = new Variable(yaml);
    expect(item is Variable, isTrue);
    expect(item.annotations is List, isTrue);
    expect(item.comment is String, isTrue);
    expect(item.setterParameter, isNull);
    expect(item.type is NestedType, isTrue);
  });
  
  test('setter_test', () {
    var currentMap = loadYaml(setter);
    var item = new Variable(currentMap, isSetter: true);
    expect(item is Variable, isTrue);
    expect(item.annotations is List, isTrue);
    expect(item.comment is String, isTrue);
    expect(item.type is NestedType, isTrue);
    
    expect(item.setterParameter is Parameter, isTrue);
    var parameter = item.setterParameter;
    expect(parameter.type is NestedType, isTrue);
    expect(parameter.annotations is List, isTrue);
  });
  
  test('one_level_generic_variable_test', () {
    var currentMap = loadYaml(generic_one_level_variable);
    var item = new Variable(currentMap);
    expect(item is Variable, isTrue);
    expect(item.type is NestedType, isTrue);
    
    var returnType = item.type;
    expect(returnType.outer is LinkableType, isTrue);
    expect(returnType.inner is List<NestedType>, isTrue);
    
    var innerType = returnType.inner.first;
    expect(innerType.outer is LinkableType, isTrue);
    expect(innerType.inner is List<NestedType>, isTrue);
    expect(innerType.inner, isEmpty);
  });
  
  test('two_level_generic_variable_test', () {
    var currentMap = loadYaml(generic_two_level_variable);
    var item = new Variable(currentMap);
    expect(item is Variable, isTrue);
    expect(item.type is NestedType, isTrue);
    
    var returnType = item.type;
    expect(returnType.outer is LinkableType, isTrue);
    expect(returnType.inner is List<NestedType>, isTrue);
    
    var innerType = returnType.inner.first;
    expect(innerType.outer is LinkableType, isTrue);
    expect(innerType.inner is List<NestedType>, isTrue);
    
    var firstInner = innerType.inresponsener.first;
    expect(firstInner, isNotNull);
    expect(firstInner is NestedType, isTrue);
    expect(firstInner.inner is List<NestedType>, isTrue);
    expect(firstInner.inner, isEmpty);
    expect(firstInner.outer is LinkableType, isTrue);
    
    var secondInner = innerType.inner[1];
    expect(secondInner, isNotNull);
    expect(secondInner is NestedType, isTrue);
    expect(secondInner.inner is List<NestedType>, isTrue);
    expect(secondInner.inner, isEmpty);
    expect(secondInner.outer is LinkableType, isTrue);
  });
  
  test('method_test', () {
    // Check that read_yaml reads the right data.
    retrieveFileContents('yaml/method.yaml').then(expectAsync1((data) {
      expect(data, equals(method));
    }));
  
    var yaml = loadYaml(method);
    var item = new Method(yaml);
    expect(item is Method, isTrue);
 
    expect(item.type is NestedType, isTrue);
    expect(item.parameters is List, isTrue);
    expect(item.parameters.first is Parameter, isTrue);
    expect(item.parameters.first.type is NestedType, isTrue);
  });
  
  test('clazz_test', () {
    // Check that read_yaml reads the right data.
    retrieveFileContents('yaml/class.yaml').then(expectAsync1((data) {
      expect(data, equals(clazz));
    }));
    
    // TODO(tmandel): Add tests for inherited methods/variables and superclass
    // comments.
    //   * Check comment content and inherited content
    //   * Check inheritedFrom and commentFrom
    //   * Check subclasses
    
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
    expect(method.type is NestedType, isTrue);
    
    var constructor = item.constructs.content.first;
    expect(constructor is Method, isTrue);
    expect(constructor.isConstructor, isTrue);
    expect(constructor.decoratedName != constructor.name, isTrue);
    
    var implements = item.implements;
    expect(implements is List, isTrue);
    implements.forEach((interface) => 
        expect(interface is LinkableType, isTrue));
    
    var superClass = item.superClass;
    expect(superClass is LinkableType, isTrue);
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
    expect(itemAutomatic.abstractClasses.content.length, 
        equals(itemManual.abstractClasses.content.length));
    
    expect(itemManual.classes is Category, isTrue);
    expect(itemManual.errors is Category, isTrue);
    expect(itemManual.typedefs is Category, isTrue);
    expect(itemManual.variables is Category, isTrue);
    expect(itemManual.functions is Category, isTrue);
    expect(itemManual.operators is Category, isTrue);

    var clazz = itemManual.classes.content.first;
    expect(clazz is Class, isTrue);
    clazz.loadValues(loadYaml(clazzA));
    
    var implements = clazz.implements;
    implements.forEach((element) => expect(element is LinkableType, isTrue));
  });
  
  // Test that links that are in scope are aliased to the correct objects.
  test('dependencies_test', () {
    var currentMap = loadYaml(dependencies);
    var library = new Library(currentMap);

    var classes = library.classes;
    var variables = library.variables;
    var functions = library.functions;

    var variable = variables.content.first;
    var classA, classB, classC;
    classes.content.forEach((element) {
      if (element.name == 'A') classA = element;
      if (element.name == 'B') classB = element;
      if (element.name == 'C') classC = element;
    });
    var function = functions.content.first;

    expect(classA.isLoaded, isFalse);
    expect(classB.isLoaded, isFalse);
    expect(classC.isLoaded, isFalse);
    
    classA.loadValues(loadYaml(clazzA));
    classB.loadValues(loadYaml(clazzB));
    classC.loadValues(loadYaml(clazzC));
    
    // Test that the destination of the links are aliased with the right class.                       
    var location = pageIndex[variable.type.outer.location];
    expect(location, equals(classA));

    location = pageIndex[function.type.outer.location];
    expect(location, equals(classA));

    var parameter = function.parameters.first;
    location = pageIndex[parameter.type.outer.location];
    expect(location, equals(classA));

    var implements = classA.implements.first;
    location = pageIndex[implements.location];
    expect(location, equals(classB));

    var superClass = classC.superClass;
    location = pageIndex[superClass.location];
    expect(location, equals(classA));
  });
  
  // Test that search returns the desired members 
  test('many_library_index_search_test', () {
    index = {};
    var members = manyLibrariesIndex.split('\n');
    members.forEach((element) {
      var splitElements = element.split(' ');
      index[splitElements[0]] = splitElements[1];
    });
    
    var results = lookupSearchResults('dart', 10);
    // Expect the top 4 results to be libraries.
    for (int i = 0; i < 4; i++) {
      expect(index[results[i].element], equals('library'));
    }
    
    results = lookupSearchResults('object', 10);
    expect(results[0].element, equals('dart.core.Object'));
    for (int i = 1; i < 4; i++) {
      expect(results[i].element.startsWith('dart.core.Object.'), isTrue);
      expect(results[i].score, equals(results[1].score));
    }
  });
}