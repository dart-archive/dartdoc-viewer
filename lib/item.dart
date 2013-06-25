library category_item;

import 'dart:html';

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/read_yaml.dart';

/**
 * Represents anything that can store information. 
 */
@observable
class CategoryItem {
  List<CategoryItem> content = toObservable([]);
  String comment = "";
  
  /// A string representing the path to this [CategoryItem] from the homepage.
  @observable String path;
  
  // Empty constructor needed as the super constructor for Literals. 
  CategoryItem();
  
  /**
   * Returns a CategoryItem based off a map input based off YAML. 
   */
  CategoryItem.fromYaml(yaml, {String previous: "", List<String> skip}) {
    if (skip == null) skip = [];
    if (yaml is Map) {
      yaml.keys.forEach((k) {
        // Since each object has a name field, it doesn't need a name category.
        // TODO(tmandel): Only have name field for libraries in docgen output.
        if (k == "comment") {
          this.comment = yaml[k];
        } else if (previous == "classes") {
          content.add(new Class.fromYaml(yaml[k]));
        } else if (previous == "functions" || previous == "methods") {
          content.add(new Method.fromYaml(yaml[k]));
        } else if (previous == "variables") {
          content.add(new Variable.fromYaml(yaml[k]));
        } else if (k != "name" && k != "qualifiedname" && !skip.contains(k)) {
          content.add(Category._isCategoryKey(k) ? 
            new Category.fromYaml(k, yaml[k]) : 
              new Item.fromYaml(k, yaml[k]));
        }
      });
    } else if (yaml is List) {
      yaml.forEach((n) => content.add(new Literal(n)));
    } else {
      content.add(new Literal(yaml));
    }
  }
}

/**
 * An item that has more content under it, which will be shown in another page.
 * Content can be other [Item], [Category], or [Literal] objects. 
 */
class Item extends CategoryItem {
  String _name;
  
  String qualifiedName;
  
  String get name => _name;
 
  /// the name of this [Item] without any appended information.
  String get simpleName => _name;
  
  // Default constructor needed for Variable object.
  Item();
  
  Item.fromYaml(String this._name, yaml, {List<String> skip}) : 
    super.fromYaml(yaml, skip: skip) {
      qualifiedName = yaml['qualifiedname'];
  }
}

/// Changes qualified names into a path format.
String convertQualified(String qualified) {
  return "${qualified.replaceAll(".", "/")}/";
}

/**
 * An [Item] representing a class.
 */
class Class extends Item {
  Class superclass;
  bool isAbstract;
  bool isTypedef;
  List<String> _implemented;
  
  Class.fromYaml(yaml) : super.fromYaml(yaml['name'], yaml, 
      skip: ['abstract', 'typedef', 'implements']) {
        isAbstract = yaml['abstract'] == "true";
        isTypedef = yaml['typedef'] == "true";
        _implemented = yaml['implements'];
        qualifiedName = yaml['qualifiedname'];
  }
  
  /// Decorated name based on properties of this [Class]
  String get name => isAbstract ? "abstract class ${this._name}" :
    isTypedef ? "typedef ${this._name}" : "class ${this._name}";
    
  /// List of paths to be used for linking implemented interfaces.
  Iterable get implemented => _implemented == null ? [] : 
      _implemented.map((element) => convertQualified(element));
}

/**
 * An [Item] representing a function or method.
 */
class Method extends Item {
  bool isStatic;
  String returnType; // Should be an Item when links work.
  List<Parameter> parameters;
  
  Method.fromYaml(yaml) : super.fromYaml(yaml['name'], yaml,
      skip: ['static', 'return', 'parameters']) {
        isStatic = yaml['static'] == "true";
        returnType = yaml['return'];
        parameters = _getParameters(yaml['parameters']);
        qualifiedName = yaml['qualifiedname'];
  }
  
  /// Retrieves [Parameter] objects describing this method's parameters.
  List<Parameter> _getParameters(Map parameters) {
    var values = [];
    if (parameters != null) {
      parameters.forEach((name, data) {
        values.add(new Parameter(name, data['optional'] == "true",
            data['named'] == "true", data['default'] == "true",
            data['type'], data['value'], data['qualifiedname']));
      });
    }
    return values;
  }
  
  String get name => isStatic ? "static $_name" : _name;
  
  Element get link => new Element.html("<a>$returnName</a>");
  
  Item get location => pageIndex[convertQualified(returnType)];
  
  String get simpleType => this.returnType.split('.').last;
  
}

/**
 * A parameter to a method/function with its associated properties.
 */
class Parameter {
  String _name;
  bool isOptional;
  bool isNamed;
  bool hasDefault;
  String _type; // is a qualified name
  String defaultValue;
  String qualifiedName;
  
  Parameter(this._name, this.isOptional, this.isNamed, this.hasDefault,
      this._type, this.defaultValue, this.qualifiedName);
  
  String get name {
    var decorated = _name;
    if (hasDefault) {
      if (isNamed) {
        decorated = "$decorated: $defaultValue";
      } else {
        decorated = "$decorated=$defaultValue";
      }
    }
    return decorated;
  }
  
  String get type => convertQualified(_type);
  
  Item get location => pageIndex[type];
  
  String get simpleType => this._type.split('.').last;
}

/**
 * An [Item] representing a variable with its associated properties.
 */
class Variable extends Item {
  bool isFinal;
  bool isStatic;
  String type;
  
  // Since variables do not contain subcategories, a call to super.fromYaml
  // is not needed.
  Variable.fromYaml(yaml) {
    this._name = yaml['name'];
    this.comment = yaml['comment'];
    this.isFinal = yaml['final'] == "true";
    this.isStatic = yaml['static'] == "true";
    this.type = yaml['type'];
    this.qualifiedName = yaml['qualifiedname'];
  }
  
  /// Decorated name based on variable return type and properties.
  String get name {
    var prefix = isStatic ? "static" : "";
    return isFinal ? "$prefix final $_name" : "$prefix $_name";
  }
  
  Element get link => new Element.html("<a>$simpleType</a>");
  
  Item get location => pageIndex[convertQualified(type)];
  
  String get simpleType => this.type.split('.').last;
}

/**
 * An item at its lowest level, and have no more layers under it. 
 */
class Literal extends CategoryItem {
  String content;
  
  Literal(String this.content);
}

/**
 * Category is a container for CategoryItems. 
 */
class Category extends CategoryItem {
  String name;
  
  /**
   * Words that are [Category] headings should go in this list. 
   */
  static const List<String> _categoryKey = const [
    "comment", "variables", "functions", "classes", "final", "static", "type",
    "return", "parameters", "optional", "named", "default", "value", 
    "superclass", "abstract", "typedef", "implements", "methods"
  ];
  
  Category.fromYaml(String name, yaml) : 
    super.fromYaml(yaml, previous: name) {
    this.name = name;
  }
  
  static bool _isCategoryKey(String key) => _categoryKey.contains(key);
}