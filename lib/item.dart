library category_item;

import 'dart:html';
import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/read_yaml.dart';

/**
 * Anything that holds values and can be displayed.
 */
@observable 
class Container {
  String name;
  String comment = "";
}

/**
 * A [Container] that holds other containers.
 */
class CompositeContainer extends Container {
  List<Container> content = [];
}

// Combines all paragraph elements into one for conversion to an HTML Element.
String _mergeCommentParagraphs(String comment) {
  if (comment == null) return "";
  return comment.replaceAll("</p><p>", " ");
}

/**
 * A [CompositeContainer] that contains other [Container]s to be displayed.
 */
class Category extends CompositeContainer {
  Category.forClasses(Map yaml) {
    this.name = "Classes";
    yaml.keys.forEach((key) => content.add(new Class(yaml[key])));
  }
  
  Category.forVariables(Map yaml) {
    this.name = "Variables";
    yaml.keys.forEach((key) => content.add(new Variable(yaml[key])));
  }
  
  Category.forFunctions(Map yaml, String name) {
    this.name = name;
    yaml.keys.forEach((key) => content.add(new Method(yaml[key])));
  }
}

/**
 * A [CompositeContainer] synonymous with a page.
 */
abstract class Item extends CompositeContainer {
  /// A string representing the path to this [Item] from the homepage.
  @observable String path;
  
  /// [Item]'s name with its properties properly appended. 
  String get decoratedName;
}

/**
 * An [Item] that describes a single Dart library.
 */
class Library extends Item {
  
  Library(Map yaml) {
    this.name = yaml['name'];
    this.comment = _mergeCommentParagraphs(yaml['comment']);
    if (yaml['classes'] != null) {
      content.add(new Category.forClasses(yaml['classes']));
    }
    if (yaml['variables'] != null) {
      content.add(new Category.forVariables(yaml['variables']));
    }
    if (yaml['functions'] != null) {
      content.add(new Category.forFunctions(yaml['functions'], "Functions"));
    }
  }
  
  String get decoratedName => "library $name";
}

/**
 * An [Item] that describes a single Dart class.
 */
class Class extends Item {
  
  String superClass;
  bool isAbstract;
  bool isTypedef;
  List<LinkableType> implements;
  
  Class(Map yaml) {
    this.name = yaml['name'];
    this.comment = _mergeCommentParagraphs(yaml['comment']);
    if (yaml['variables'] != null) {
      content.add(new Category.forVariables(yaml['variables']));
    }
    if (yaml['methods'] != null) {
      content.add(new Category.forFunctions(yaml['methods'], "Methods"));
    }
    this.isAbstract = yaml['abstract'] == "true";
    this.isTypedef = yaml['typedef'] == "true";
    this.implements = yaml['implements'] == null ? [] :
        yaml['implements'].map((item) => new LinkableType(item)).toList();
  }
  
  String get decoratedName => isAbstract ? "abstract class ${this.name}" :
    isTypedef ? "typedef ${this.name}" : "class ${this.name}";
  
}

/**
 * An [Item] that describes a single Dart method.
 */
class Method extends Item {
  
  bool isStatic;
  LinkableType type;
  List<Parameter> parameters;
  
  Method(Map yaml) {
    this.name = yaml['name'];
    this.comment = _mergeCommentParagraphs(yaml['comment']);
    this.isStatic = yaml['static'] == "true";
    this.type = new LinkableType(yaml['return']);
    this.parameters = _getParameters(yaml['parameters']);
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
  
  String get decoratedName => isStatic ? "static $name" : name;
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
    this.isOptional = yaml['optional'] == "true";
    this.isNamed = yaml['named'] == "true";
    this.hasDefault = yaml['default'] == "true";
    this.type = new LinkableType(yaml['type']);
    this.defaultValue = yaml['value'];
  }
  
  String get decoratedName {
    var decorated = name;
    if (hasDefault) {
      if (isNamed) {
        decorated = "$decorated: $defaultValue";
      } else {
        decorated = "$decorated=$defaultValue";
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
  LinkableType type;
  
  Variable(Map yaml) {
    this.name = yaml['name'];
    this.comment = _mergeCommentParagraphs(yaml['comment']);
    this.isFinal = yaml['final'] == "true";
    this.isStatic = yaml['static'] == "true";
    this.type = new LinkableType(yaml['type']);
  }
  
  /// The attributes of this variable to be displayed before it.
  String get prefix {
    var prefix = isStatic ? "static " : "";
    return isFinal ? "${prefix}final" : prefix;
  }
}

/**
 * A Dart type that should link to other [Item]s.
 */
class LinkableType {
  String type;

  LinkableType(this.type);
  
  /// The simple name for this type.
  String get simpleType => type.split('.').last;
  
  /// The [Item] describing this type.
  Item get location => pageIndex["${type.replaceAll(".", "/")}/"];

}