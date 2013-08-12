/**
 * Library to hold all the data needed in the app. 
 */
library data;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/item.dart';

// Pages generated from the YAML file. Keys are the title of the pages. 
Map<String, Item> pageIndex = toObservable({});

// Since library names can contain '.' characters, they must be mapped to
// a new form for linking purposes. This maps original library names to names
// with '-' characters replacing the '.' characters for consistency.
Map<String, String> libraryNames = {};

// Linking to operators and setters fails because HTML ids are limited to 
// a-z, A-Z, digits, hyphens, underscores, colons, and periods. This map
// maps invalid id characters to valid id strings.
Map<String, String> idMap = {
  '+' : '-plus-',
  '-' : '-minus-',
  '[' : '-leftb-',
  ']' : '-rightb-',
  '!' : '-not-',
  '~' : '-tilde-',
  '*' : '-times-',
  '%' : '-mod-',
  '<' : '-lt-',
  '>' : '-gt-',
  '&' : '-and-',
  '^' : '-xor-',
  '|' : '-or-',
  '?' : '-qmark-',
  ':' : '-colon-',
  '.' : '-dot-',
  '=' : '-equals-',
  '/' : '-slash-'
};

String findLibraryName(String type) {
  var current = type;
  while (true) {
    if (libraryNames[current] != null) {
      return type.replaceFirst(current, libraryNames[current]);
    } else {
      var index = current.lastIndexOf('.');
      if (index == -1) return type;
      current = index != -1 ? current.substring(0, index) : '';
    }
  }
}