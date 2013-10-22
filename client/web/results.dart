library results;

import 'package:dartdoc_viewer/data.dart';
import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/search.dart';
import 'package:polymer/polymer.dart';
import 'member.dart';
import 'dart:html';

/**
 * An HTML representation of a Search Result.
 */
@CustomTag("search-result")
class Result extends AnchorElement with Polymer, Observable {

  Result.created() : super.created();

  var _item;

  @published get item => _item;
  set item(newItem) {
    var oldItem = item;
    var oldObservables = [descriptiveName, descriptiveType, outerLibrary];
    _item = newItem;
    notifyPropertyChange(#item, oldItem, newItem);
    notifyPropertyChange(#descriptiveName, oldObservables.first,
        descriptiveName);
    notifyPropertyChange(#descriptiveType, oldObservables[1],
        descriptiveName);
    notifyPropertyChange(#outerLibrary, oldObservables.last, descriptiveName);
  }

  get applyAuthorStyles => true;

  @observable String get membertype => item == null ? 'none' : item.type;
  @observable String get qualifiedname => item == null ? 'none' : item.element;

  /// The name of this member.
  String get descriptiveName {
    if (qualifiedname == null) return '';
    var name = qualifiedname.split('.');
    if (membertype == 'library') {
      if (name.first == 'dart') {
        return 'dart:${name.last}';
      }
    } else if (membertype == 'constructor') {
      // Non-named constructors have an empty string for the last element
      // of the qualified name, so we display the class name instead.
      if (name.last == '') return name[name.length - 2];
      return '${name[name.length - 2]}.${name.last}';
    }
    return name.last;
  }

  /// The type of this member.
  String get descriptiveType {
    if (membertype == 'class' || membertype == 'library')
      return membertype;
    var owner = ownerName(qualifiedname);
    var ownerShortName = owner.split('.').last;
    var ownerType = index[owner];
    if (ownerType == 'class')
      return '$membertype in $ownerShortName';
    return membertype;
  }

  /// The library containing this member.
  String get outerLibrary {
    if (membertype == 'library') return '';
    var nameWithLibrary = findLibraryName(qualifiedname);
    var libraryName = nameWithLibrary.split('.').first;
    libraryName = libraryName.replaceAll('-', ':');
    if (libraryName.contains(':dom:'))
      libraryName = libraryName.replaceFirst(':dom:', ':');
    return 'library $libraryName';
  }
}