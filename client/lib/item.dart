library category_item;

import 'dart:async';
import 'dart:html';

import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/read_yaml.dart';
import 'package:web_ui/web_ui.dart';

// TODO(tmandel): Don't hardcode in a path if it can be avoided.
const docsPath = '../../docs/';

/**
 * Anything that holds values and can be displayed.
 */
@observable 
class Container {
  String name;
  String comment = '<span></span>';
  
  Container(this.name, [this.comment]);
}

// Wraps a comment in span element to make it a single HTML Element.
String _wrapComment(String comment) {
  if (comment == null) comment = '';
  return '<span>$comment</span>';
}

/**
 * A [Container] that contains other [Container]s to be displayed.
 */
class Category extends Container {
  
  List<Container> content = [];
  
  Category.forClasses(Map yaml, {bool isAbstract: false}) : 
      super(isAbstract ? 'Abstract Classes' : 'Classes') {
    if (yaml != null)
      yaml.keys.forEach((key) => 
          content.add(new Class(yaml[key], isAbstract: isAbstract)));
  }
  
  Category.forErrors(Map yaml) : super('Exceptions') {
    if (yaml != null)
      yaml.keys.forEach((key) => content.add(new Class(yaml[key])));
  }
  
  Category.forVariables(Map variables, Map getters, Map setters) : 
      super('Properties') {
    // TODO(tmandel): Setters and getters should have the same schema as
    // variables in the yaml input.
    if (variables != null) {
      variables.keys.forEach((key) {
        var variable = variables[key];
        content.add(new Variable(key, variable['comment'],
            variable['final'] == 'true', variable['static'] == 'true',
            variable['type']));
      });
    }
    if (getters != null) {
      getters.keys.forEach((key) {
        var variable = getters[key];
        content.add(new Variable(key, variable['comment'], false,
            variable['static'] == 'true', variable['return'], isGetter: true));
      });
    }
    if (setters != null) {
      setters.keys.forEach((key) {
        var variable = setters[key];
        var parameterName = variable['parameters'].keys.first;
        var parameter = new Parameter(parameterName,
            variable['parameters'][parameterName]);
        content.add(new Variable(key, variable['comment'], false,
            variable['static'] == 'true', "void", isSetter: true,
            setterParameter: parameter));
      });
    }
  }
  
  Category.forFunctions(Map yaml, String name, {bool isConstructor: false, 
      String className: '', bool isOperator: false}) : super(name) {
    if (yaml != null) {
      yaml.keys.forEach((key) =>
        content.add(new Method(yaml[key], isConstructor: isConstructor, 
            className: className, isOperator: isOperator)));
    }
  }
}

/**
 * A [Container] synonymous with a page.
 */
class Item extends Container {
  /// A list of [Item]s representing the path to this [Item].
  List<Item> path = [];
  
  Item(String name, [String comment]) : super(name, comment);
  
  /// [Item]'s name with its properties properly appended. 
  String get decoratedName => name;
}

/**
 * An [Item] with no content. This is used to facilitate lazy loading.
 */
class Placeholder extends Item {
  
  /// The path to the file with the real data relative to [docsPath].
  String location;
  
  Placeholder(String name, this.location) : super(name);
}

/**
 * An [Item] containing all of the [Library] and [Placeholder] objects.
 */
class Home extends Item {
  
  /// All libraries being viewed from the homepage.
  List<Item> libraries;
  
  /// The constructor parses the [libraries] input and constructs
  /// [Placeholder] objects to display before loading libraries.
  Home(List libraries) : super('Dart API Reference') {
    this.libraries = [];
    for (String library in libraries) {
      var libraryName = library.replaceAll('.yaml', '');
      libraryNames[libraryName] = libraryName.replaceAll('.', '-');
      this.libraries.add(new Placeholder(libraryName, library));
    };
  }
  
  /// Loads the library's data and returns a [Future] for external handling.
  Future loadLibrary(Placeholder place) {
    var data = retrieveFileContents('$docsPath${place.location}');
    return data.then((response) {
      var lib = loadData(response);
      var index = libraries.indexOf(place);
      buildHierarchy(lib, lib);
      libraries.remove(place);
      libraries.insert(index, lib);
      return lib;
    });
  }
  
  /// Checks if [library] is defined in [libraries].
  bool contains(String library) => libraryNames.values.contains(library);
  
  /// Returns the [Item] representing [libraryName].
  // TODO(tmandel): Stop looping through 'libraries' so much. Possibly use a 
  // map from library names to their objects.
  Item itemNamed(String libraryName) {
    return libraries.firstWhere((lib) => libraryNames[lib.name] == libraryName,
        orElse: () => null);
  }
}


/// Runs through the member structure and creates path information.
void buildHierarchy(Item page, Item previous) {
  page.path
    ..addAll(previous.path)
    ..add(page);
  if (page is Class) {
    [page.constructs, page.operators].forEach((category) =>
      category.content.forEach((item) {
        buildHierarchy(item, page);
      }));
  }
  if (page is Library || page is Class) {
    page.functions.content.forEach((method) {
      buildHierarchy(method, page);
    });
    if (page is Library) {
      [page.classes, page.abstractClasses].forEach((category) =>
        category.content.forEach((clazz) {
          buildHierarchy(clazz, page);
        }));
    }
  }
}

/**
 * An [Item] that describes a single Dart library.
 */
class Library extends Item {
  
  Category classes;
  Category abstractClasses;
  Category errors;
  Category variables;
  Category functions;
  Category operators;

  Library(Map yaml) : super(yaml['name'], _wrapComment(yaml['comment'])) {
    var classes, abstractClasses, exceptions;
    if (yaml['classes'] != null) {
      classes = yaml['classes']['class'];
      abstractClasses = yaml['classes']['abstract'];
      exceptions = yaml['classes']['error'];
    }
    errors = new Category.forErrors(exceptions);
    this.classes = new Category.forClasses(classes);
    this.abstractClasses =
        new Category.forClasses(abstractClasses, isAbstract: true);
    var setters, getters, methods, opers;
    if (yaml['functions'] != null) {
      setters = yaml['functions']['setters'];
      getters = yaml['functions']['getters'];
      methods = yaml['functions']['methods'];
      opers = yaml['functions']['operators'];
    }
    variables = new Category.forVariables(yaml['variables'], getters, setters);
    functions = new Category.forFunctions(methods, 'Functions');
    operators = new Category.forFunctions(opers, 'Operators', 
        isOperator: true);
  }

  String get decoratedName => '$name library';
}

/**
 * An [Item] that describes a single Dart class.
 */
class Class extends Item {

  Category functions;
  Category variables;
  Category constructs;
  Category operators;

  LinkableType superClass;
  bool isAbstract;
  bool isTypedef;
  List<LinkableType> implements;

  Class(Map yaml, {bool isAbstract: false}) : 
      super(yaml['name'], _wrapComment(yaml['comment'])){
    var setters, getters, methods, operators, constructors;
    if (yaml['methods'] != null) {
      setters = yaml['methods']['setters'];
      getters = yaml['methods']['getters'];
      methods = yaml['methods']['methods'];
      operators = yaml['methods']['operators'];
      constructors = yaml['methods']['constructors'];
    }
    variables = new Category.forVariables(yaml['variables'], getters, setters);
    functions = new Category.forFunctions(methods, 'Functions');
    this.operators = new Category.forFunctions(operators, 'Operators',
        isOperator: true);
    constructs = new Category.forFunctions(constructors, 'Constructors', 
        isConstructor: true, className: this.name);
    this.superClass = new LinkableType(yaml['superclass']);
    this.isAbstract = isAbstract;
    this.isTypedef = yaml['typedef'] == 'true';
    this.implements = yaml['implements'] == null ? [] :
        yaml['implements'].map((item) => new LinkableType(item)).toList();
  }

  String get decoratedName => isAbstract ? '${this.name} abstract class' :
    isTypedef ? '${this.name} typedef' : '${this.name} class';
}


/**
 * An [Item] that describes a single Dart method.
 */
class Method extends Item {

  bool isStatic;
  bool isConstructor;
  String className;
  bool isOperator;
  LinkableType type;
  List<Parameter> parameters;

  Method(Map yaml, {bool isConstructor: false, String className: '', 
      bool isOperator: false}) : super(yaml['name'], yaml['comment']) {
    this.isStatic = yaml['static'] == 'true';
    this.isOperator = isOperator;
    this.isConstructor = isConstructor;
    this.type = new LinkableType(yaml['return']);
    this.parameters = _getParameters(yaml['parameters']);
    this.className = className;
  }

  /// Creates [Parameter] objects for each parameter to this method.                                  
  List<Parameter> _getParameters(Map parameters) {
    var values = [];
    if (parameters != null) {
      parameters.forEach((name, data) {
        values.add(new Parameter(name, data));
      });
    }
    return values;
  }

  String get decoratedName => isStatic ? 'static $name' :
    isConstructor ? (name != '' ? '$className.$name' : className) : name;
}

/**
 * A single parameter to a [Method].
 */
class Parameter {
  
  String name;
  bool isOptional;
  bool isNamed;
  bool hasDefault;
  LinkableType type;
  String defaultValue;
  
  Parameter(this.name, Map yaml) {
    this.isOptional = yaml['optional'] == 'true';
    this.isNamed = yaml['named'] == 'true';
    this.hasDefault = yaml['default'] == 'true';
    this.type = new LinkableType(yaml['type']);
    this.defaultValue = yaml['value'];
  }
  
  String get decoratedName {
    var decorated = name;
    if (hasDefault) {
      if (isNamed) {
        decorated = '$decorated: $defaultValue';
      } else {
        decorated = '$decorated=$defaultValue';
      }
    }
    return decorated;
  }
}

/**
 * A [Container] that describes a single Dart variable.
 */
class Variable extends Container {
  
  bool isFinal;
  bool isStatic;
  bool isGetter;
  bool isSetter;
  Parameter setterParameter;
  LinkableType type;

  // Since getters and setters are treated as variables, this does not                                
  // take in a map and instead takes in all properties.
  // TODO(tmandel): Getters and setters should have the same schema
  // as variables in yaml input.
  Variable(String name, String comment, this.isFinal, this.isStatic,
      String type, {bool isGetter: false, bool isSetter: false,
      Parameter setterParameter: null}) :
        super(name, _wrapComment(comment)) {
    this.setterParameter = setterParameter;
    this.isGetter = isGetter;
    this.isSetter = isSetter;
    this.type = new LinkableType(type);
  }

  /// The attributes of this variable to be displayed before it.                                      
  String get prefix {
    var prefix = isStatic ? 'static ' : '';
    return isFinal ? '${prefix}final' : prefix;
  }
}

/**
 * A Dart type that should link to other [Item]s.
 */
class LinkableType {

  /// The resolved qualified name of the type this [LinkableType] represents.
  String type;
  
  /// The constructor resolves the library name by finding the correct library
  /// from [libraryNames] and changing [type] to match.
  LinkableType(String type) {
    var current = type;
    this.type;
    while (this.type == null) {
      if (libraryNames[current] != null) {
        this.type = type.replaceFirst(current, libraryNames[current]);
      } else {
        var index = current.lastIndexOf('.');
        if (index == -1) this.type = type;
        current = index != -1 ? current.substring(0, index) : '';
      }
    }
  }

  /// The simple name for this type.
  String get simpleType => type.split('.').last;

  /// The [Item] describing this type if it has been loaded, otherwise null.
  List<String> get location => type.split('.');
}