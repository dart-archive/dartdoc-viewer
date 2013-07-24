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
  
  Category.forClasses(Map yaml, String name, {bool isAbstract: false})
      : super(name) {
    if (yaml != null) {
      yaml.keys.forEach((key) => 
        content.add(new Class(yaml[key], isAbstract: isAbstract)));
    }
  }
  
  Category.forVariables(Map variables, Map getters, Map setters) 
      : super('Properties') {
    if (variables != null) {
      variables.keys.forEach((key) {
        content.add(new Variable(variables[key]));
      });
    }
    if (getters != null) {
      getters.keys.forEach((key) {
        content.add(new Variable(getters[key], isGetter: true));
      });
    }
    if (setters != null) {
      setters.keys.forEach((key) {
        content.add(new Variable(setters[key], isSetter: true ));
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
  
  Category.forTypedefs(Map yaml) : super ('Typedefs') {
    if (yaml != null) {
      yaml.keys.forEach((key) =>
        content.add(new Typedef(yaml[key])));
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
  pageIndex[page.qualifiedName] = page;
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
      [page.classes, page.abstractClasses, page.typedefs].forEach((category) =>
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
  Category typedefs;
  Category variables;
  Category functions;
  Category operators;
  String qualifiedName;

  Library(Map yaml) : super(yaml['name'], _wrapComment(yaml['comment'])) {
    qualifiedName = yaml['qualifiedname'];
    var classes, abstractClasses, exceptions, typedefs;
    var allClasses = yaml['classes'];
    if (allClasses != null) {
      classes = allClasses['class'];
      abstractClasses = allClasses['abstract'];
      exceptions = allClasses['error'];
      typedefs = allClasses['typedef'];
    }
    this.typedefs = new Category.forTypedefs(typedefs);
    errors = new Category.forClasses(exceptions, 'Exceptions');
    this.classes = new Category.forClasses(classes, 'Classes');
    this.abstractClasses =
        new Category.forClasses(abstractClasses, 'Abstract Classes',
            isAbstract: true);
    var setters, getters, methods, operators;
    var allFunctions = yaml['functions'];
    if (allFunctions != null) {
      setters = allFunctions['setters'];
      getters = allFunctions['getters'];
      methods = allFunctions['methods'];
      operators = allFunctions['operators'];
    }
    variables = new Category.forVariables(yaml['variables'], getters, setters);
    functions = new Category.forFunctions(methods, 'Functions');
    this.operators = new Category.forFunctions(operators, 'Operators', 
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
  List<LinkableType> annotations;
  List<LinkableType> implements;
  String qualifiedName;

  Class(Map yaml, {bool isAbstract: false})
      : super(yaml['name'], _wrapComment(yaml['comment'])){
    qualifiedName = yaml['qualifiedname'];
    var setters, getters, methods, operators, constructors;
    var allMethods = yaml['methods'];
    if (allMethods != null) {
      setters = allMethods['setters'];
      getters = allMethods['getters'];
      methods = allMethods['methods'];
      operators = allMethods['operators'];
      constructors = allMethods['constructors'];
    }
    variables = new Category.forVariables(yaml['variables'], getters, setters);
    functions = new Category.forFunctions(methods, 'Functions');
    this.operators = new Category.forFunctions(operators, 'Operators',
        isOperator: true);
    constructs = new Category.forFunctions(constructors, 'Constructors', 
        isConstructor: true, className: this.name);
    this.superClass = new LinkableType(yaml['superclass']);
    this.isAbstract = isAbstract;
    this.annotations = yaml['annotations'] == null ? [] :
        yaml['annotations'].map((item) => new LinkableType(item)).toList();
    this.implements = yaml['implements'] == null ? [] :
        yaml['implements'].map((item) => new LinkableType(item)).toList();
  }

  String get decoratedName => isAbstract ?
      '${this.name} abstract class' : '${this.name} class';
}

/**
 * An [Item] that describes a Dart member with parameters.
 */
class Parameterized extends Item {
  
  List<Parameter> parameters;
  
  Parameterized(String name, String comment) : super(name, comment);
  
  /// Creates [Parameter] objects for each parameter to this method.
  List<Parameter> getParameters(Map parameters) {
    var values = [];
    if (parameters != null) {
      parameters.forEach((name, data) {
        values.add(new Parameter(name, data));
      });
    }
    return values;
  }
}

/**
 * An [Item] that describes a single Dart typedef.
 */
class Typedef extends Parameterized {
  
  String qualifiedName;
  LinkableType type;
  List<LinkableType> annotations;
  
  Typedef(Map yaml) : super(yaml['name'], _wrapComment(yaml['comment'])) {
    qualifiedName = yaml['qualifiedname'];
    type = new LinkableType(yaml['return']);
    parameters = getParameters(yaml['parameters']);
    annotations = yaml['annotations'] == null ? [] :
      yaml['annotations'].map((item) => new LinkableType(item)).toList();
  }
  
  String get decoratedName => '$name typedef';
}

/**
 * An [Item] that describes a single Dart method.
 */
class Method extends Parameterized {

  bool isStatic;
  bool isConstructor;
  String className;
  bool isOperator;
  LinkableType type;
  List<LinkableType> annotations;
  String qualifiedName;

  Method(Map yaml, {bool isConstructor: false, String className: '', 
      bool isOperator: false}) 
        : super(yaml['name'], _wrapComment(yaml['comment'])) {
    qualifiedName = yaml['qualifiedname'];
    this.isStatic = yaml['static'] == 'true';
    this.isOperator = isOperator;
    this.isConstructor = isConstructor;
    this.type = new LinkableType(yaml['return']);
    this.parameters = getParameters(yaml['parameters']);
    this.className = className;
    this.annotations = yaml['annotations'] == null ? [] :
      yaml['annotations'].map((item) => new LinkableType(item)).toList();
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
  List<LinkableType> annotations;
  
  Parameter(this.name, Map yaml) {
    this.isOptional = yaml['optional'] == 'true';
    this.isNamed = yaml['named'] == 'true';
    this.hasDefault = yaml['default'] == 'true';
    this.type = new LinkableType(yaml['type']);
    this.defaultValue = yaml['value'];
    this.annotations = yaml['annotations'] == null ? [] :
      yaml['annotations'].map((item) => new LinkableType(item)).toList();
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
  String qualifiedName;
  List<LinkableType> annotations = [];

  Variable(Map yaml, {bool isGetter: false, bool isSetter: false})
      : super(yaml['name'], _wrapComment(yaml['comment'])) {
    qualifiedName = yaml['qualifiedname'];
    this.isGetter = isGetter;
    this.isSetter = isSetter;
    isFinal = yaml['final'] == 'true';
    isStatic = yaml['static'] == 'true';
    if (isGetter) {
      type = new LinkableType(yaml['return']);
    } else if (isSetter) {
      type = new LinkableType('void');
      var parameters = yaml['parameters'];
      var parameterName = parameters.keys.first;
      setterParameter = new Parameter(parameterName, 
          parameters[parameterName]);
    } else {
      type = new LinkableType(yaml['type']);
    }
    this.annotations = yaml['annotations'] == null ? [] :
      yaml['annotations'].map((item) => new LinkableType(item)).toList();
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
  String get location => type;
}