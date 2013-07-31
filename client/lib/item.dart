library category_item;

import 'dart:async';
import 'dart:html';

import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/read_yaml.dart';
import 'package:web_ui/web_ui.dart';
import 'package:yaml/yaml.dart';

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
  
  Category.forClasses(List<String> locations, String name, 
      {bool isAbstract: false}) : super(name) {
    if (locations != null) {
      locations.forEach((key) => 
        content.add(new Class.forPlaceholder(key, isAbstract: isAbstract)));
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
      yaml.keys.forEach((key) => content.add(new Typedef(yaml[key])));
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

/// Sorts each inner [List]] by the [Item]'s qualified names.
void _sort(List<List<Item>> items) {
  items.forEach((item) {
    item.sort((Item a, Item b) =>
      a.qualifiedName.compareTo(b.qualifiedName));
  });
}

/**
 * An [Item] containing all of the [Library] and [Placeholder] objects.
 */
class Home extends Item {
  
  /// All libraries being viewed from the homepage.
  List<Item> libraries = [];
  
  /// The constructor parses the [libraries] input and constructs
  /// [Placeholder] objects to display before loading libraries.
  Home(List libraries) : super('Dart API Reference') {
    for (String library in libraries) {
      libraryNames[library] = library.replaceAll('.', '-');
      this.libraries.add(new Library.forPlaceholder(library));
    };
    _sort([this.libraries]);
  }
  
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
  if (page.path.isEmpty) {
    page.path
      ..addAll(previous.path)
      ..add(page);
    pageIndex[page.qualifiedName] = page;
  }
  if (page is Class && page.isLoaded) {
    [page.constructs, page.operators].forEach((category) =>
      category.content.forEach((item) {
        buildHierarchy(item, page);
      }));
  }
  if (page is Library || (page is Class && page.isLoaded)) {
    page.functions.content.forEach((method) {
      buildHierarchy(method, page);
    });
    if (page is Library) {
      [page.classes, page.abstractClasses, page.typedefs, page.errors]
        .forEach((category) =>
          category.content.forEach((clazz) {
            buildHierarchy(clazz, page);
          }));
    }
  }
}

/**
 * An [Item] that is lazily loaded.
 */
abstract class LazyItem extends Item {
  
  bool isLoaded = false;
  String qualifiedName;
  
  LazyItem(String qualifiedName, String name, [String comment]) 
      : super(name, comment) {
    this.qualifiedName = qualifiedName;
  }
  
  /// Loads this [Item]'s data and populates all fields.
  Future load() {
    var data = retrieveFileContents('$docsPath$qualifiedName.yaml');
    return data.then((response) {
      var yaml = loadYaml(response);
      loadValues(yaml);
      buildHierarchy(this, this);
    });
  }
  
  /// Populates all of this [Item]'s fields.
  void loadValues(Map yaml);
}

/**
 * An [Item] that describes a single Dart library.
 */
class Library extends LazyItem {
  
  Category classes;
  Category abstractClasses;
  Category errors;
  Category typedefs;
  Category variables;
  Category functions;
  Category operators;

  /// Creates a [Library] placeholder object with null fields.
  Library.forPlaceholder(String location) : super(location, location);
  
  /// Normal constructor for testing.
  Library(Map yaml) : super(yaml['qualifiedname'], yaml['name']) {
    loadValues(yaml);
    buildHierarchy(this, this);
  } 
  
  void loadValues(Map yaml) {
    this.comment = _wrapComment(yaml['comment']);
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
    _sort([this.classes.content, this.abstractClasses.content, 
           this.errors.content, this.typedefs.content, this.variables.content,
           this.functions.content, this.operators.content]);
    isLoaded = true;
  }
}

/**
 * An [Item] that describes a single Dart class.
 */
class Class extends LazyItem {
  
  Category functions;
  Category variables;
  Category constructs;
  Category operators;
  LinkableType superClass;
  bool isAbstract;
  List<LinkableType> annotations;
  List<LinkableType> implements;
  List<String> generics = [];

  /// Creates a [Class] placeholder object with null fields.
  Class.forPlaceholder(String location, {bool isAbstract: false}) 
      : super(location, location.split('.').last) {
    this.isAbstract = isAbstract;
  }
  
  /// Normal constructor for testing.
  Class(Map yaml, {bool isAbstract: false}) 
      : super(yaml['qualifiedname'], yaml['name']) {
    this.isAbstract = isAbstract;
    loadValues(yaml);
  }
  
  void loadValues(Map yaml) {
    this.comment = _wrapComment(yaml['comment']);
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
    var generics = yaml['generics'];
    if (generics != null) {
      generics.keys.forEach((generic) => this.generics.add(generic));
    }
    _sort([this.functions.content, this.variables.content, 
           this.constructs.content, this.operators.content]);
    isLoaded = true;
  }
}

/**
 * An [Item] that describes a Dart member with parameters.
 */
class Parameterized extends Item {
  
  List<Parameter> parameters;
  
  Parameterized(String name, [String comment]) : super(name, comment);
  
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
}

/**
 * An [Item] that describes a single Dart method.
 */
class Method extends Parameterized {

  bool isStatic;
  bool isAbstract;
  bool isConstant;
  bool isConstructor;
  String className;
  bool isOperator;
  List<LinkableType> annotations;
  NestedType type;
  String qualifiedName;

  Method(Map yaml, {bool isConstructor: false, String className: '', 
      bool isOperator: false}) 
        : super(yaml['name'], _wrapComment(yaml['comment'])) {
    qualifiedName = yaml['qualifiedname'];
    this.isStatic = yaml['static'] == 'true';
    this.isAbstract = yaml['abstract'] == 'true';
    this.isConstant = yaml['constant'] == 'true';
    this.isOperator = isOperator;
    this.isConstructor = isConstructor;
    this.type = new NestedType(yaml['return'].first);
    parameters = getParameters(yaml['parameters']);
    this.className = className;
    this.annotations = yaml['annotations'] == null ? [] :
      yaml['annotations'].map((item) => new LinkableType(item)).toList();
  }

  String get decoratedName => isConstructor ? 
      (name != '' ? '$className.$name' : className) : name;
}

/**
 * A single parameter to a [Method].
 */
class Parameter {
  
  String name;
  bool isOptional;
  bool isNamed;
  bool hasDefault;
  NestedType type;
  String defaultValue;
  List<LinkableType> annotations;
  
  Parameter(this.name, Map yaml) {
    this.isOptional = yaml['optional'] == 'true';
    this.isNamed = yaml['named'] == 'true';
    this.hasDefault = yaml['default'] == 'true';
    this.type = new NestedType(yaml['type'].first);
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
class Variable extends Item {
  
  bool isFinal;
  bool isStatic;
  bool isAbstract;
  bool isConstant;
  bool isGetter;
  bool isSetter;
  Parameter setterParameter;
  NestedType type;
  String qualifiedName;
  List<LinkableType> annotations;

  Variable(Map yaml, {bool isGetter: false, bool isSetter: false})
      : super(yaml['name'], _wrapComment(yaml['comment'])) {
    qualifiedName = yaml['qualifiedname'];
    this.isGetter = isGetter;
    this.isSetter = isSetter;
    isFinal = yaml['final'] == 'true';
    isStatic = yaml['static'] == 'true';
    isConstant = yaml['constant'] == 'true';
    isAbstract = yaml['abstract'] == 'true';
    if (isGetter) {
      type = new NestedType(yaml['return'].first);
    } else if (isSetter) {
      type = new NestedType(yaml['return'].first);
      var parameters = yaml['parameters'];
      var parameterName = parameters.keys.first;
      setterParameter = new Parameter(parameterName, 
          parameters[parameterName]);
    } else {
      type = new NestedType(yaml['type'].first);
    }
    this.annotations = yaml['annotations'] == null ? [] :
      yaml['annotations'].map((item) => new LinkableType(item)).toList();
  }
}

/**
 * A Dart type that potentially contains generic parameters.
 */
class NestedType {
  LinkableType outer;
  List<NestedType> inner = [];
  
  NestedType(Map yaml) {
    if (yaml == null) {
      outer = new LinkableType('void');
    } else {
      outer = new LinkableType(yaml['outer']);
      var innerMap = yaml['inner'];
      if (innerMap != null)
      innerMap.forEach((element) => inner.add(new NestedType(element)));
    }
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