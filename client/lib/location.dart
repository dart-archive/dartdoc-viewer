// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library location;

// These regular expressions are not strictly accurate for picking Dart
// identifiers out of arbitrary text, e.g. identifiers must start with an
// alphabetic or underscore, this would allow "9a" as a library name. But
// they should be sufficient for extracting them from URLs that were created
// from valid identifiers.

/// A package in one of our URIs is an identifer and ends with a slash
final packageMatch = new RegExp(r'(\w+)/');
/// A library in one of our URIs is an identifier but may contain either
/// ':' or '-' in place of the '.' that is legal in a Dart library name.
final libraryMatch = new RegExp(r'([\w\-\:]+)');
/// A member or sub-member in one of our URI's starts with a '.' and is
/// an identifier.
final memberMatch = new RegExp(r'\.(\w+)');
final anchorMatch = new RegExp(r'\#(\w+)');

// This represents a component described by a URI and can give us
// the URI given the component or vice versa.
class DocsLocation {
  String packageName;
  String libraryName;
  String memberName;
  String subMemberName;
  String anchor;

  DocsLocation.empty();

  DocsLocation(String uri) {
    _extractPieces(uri);
  }

  DocsLocation.fromList(List<String> components) {
    if (components.length > 0) packageName = components[0];
    if (components.length > 1) libraryName = components[1];
    if (components.length > 2) memberName = components[2];
    if (components.length > 3) subMemberName = components[3];
    if (components.length > 4) anchor = components[4];
  }

  void _extractPieces(String uri) {
    var position = 0;

    _check(regex) {
      var match = regex.matchAsPrefix(uri, position);
      if (match != null) {
        var matchedString = match.group(1);
        position = position + match.group(0).length;
        return matchedString;
      }
    }

    if (uri == null) return;
    packageName = _check(packageMatch);
    libraryName = _check(libraryMatch);
    memberName = _check(memberMatch);
    subMemberName = _check(memberMatch);
    anchor = _check(anchorMatch);
  }

  /// The URI hash string without its leading hash
  /// and without any trailing anchor portion, e.g. for
  /// http://site/#args/args.ArgParser#id_== it would return args/argsArgParser
  String get withoutAnchor =>
      [packagePlus, libraryPlus, memberPlus, subMemberPlus].join("");

  /// The URI hash for just the library portion of this location.
  String get libraryQualifiedName => "$packagePlus$libraryPlus";

  /// The full URI hash string without the leading hash character.
  /// e.g. for
  /// http://site/#args/args.ArgParser#id_==
  /// it would return args/argsArgParser#id_==
  String get withAnchor => withoutAnchor + anchorPlus;

  /// The package name with the trailing / separator, or the empty
  /// string if the package name is not set.
  get packagePlus => packageName == null
      ? ''
      : libraryName == null
          ? packageName
          : '$packageName/';
  /// The name of the library. This never has leading or trailing separators,
  /// so it's the same as [libraryName].
  get libraryPlus => libraryName == null ? '' :  libraryName;
  /// The name of the library member, with a leading period if the [memberName]
  /// is non-empty.
  get memberPlus => memberName == null ? '' : '.$memberName';
  /// The name of the member's sub-member (e.g. the field of a class),
  /// with a leading period if the [subMemberName] is non-empty.
  get subMemberPlus => subMemberName == null ? '' : '.$subMemberName';
  /// The trailing anchor e.g. #id_hashCode, including the leading hash.
  get anchorPlus => anchor == null ? '' : '#$anchor';

  /// Return a list of the components' basic names. Omits the anchor, but
  /// includes the package name, even if it is null.
  List<String> get componentNames =>
      [packageName]..addAll(
          [libraryName, memberName, subMemberName].where((x) => x != null));

  /// Return all component names, including the anchor, and including those
  /// which are null.
  List<String> get allComponentNames =>
      [packageName, libraryName, memberName, subMemberName, anchor];

  /// Return the simple name of the lowest-level component.
  String get name {
    if (anchor != null) return anchor;
    if (subMemberName != null) return subMemberName;
    if (memberName != null) return memberName;
    if (libraryName != null) return libraryName;
    if (packageName != null) return packageName;
    return '';
  }

  /// Return a minimal list of the items along our path, using [root] for
  /// context. The [root] is of type Home, and it returns a list of Item,
  /// but we can't see those types from here.
  List items(root) {
    // TODO(alanknight): Re-arrange the structure so that we can see
    // those types without needing to import html as well.
    var items = [];
    var package = packageName == null
        ? null
        : root.memberNamed(packageName);
    if (package != null) items.add(package);
    if (libraryName == null) return items;
    var library = items.last.memberNamed(libraryName);
    items.add(library);
    var member = memberName == null
        ? library.memberNamed(memberName) : null;
    if (member != null) {
      items.add(member);
      var subMember = subMemberName == null
          ? member.memberNamed(subMemberName)  : null;
      if (subMember != null) items.add(subMember);
    }
    return items;
  }

  /// Return the item in the list that corresponds to the thing we represent.
  /// Assumes that the items all match what we describe, so really amounts
  /// to finding the last non-nil entry.
  itemFromList(List items) => items.reversed.firstWhere((x) => x != null);

  /// Change [hash] into the form we use for identifying a doc entry within
  /// a larger page.
  String toHash(String hash) {
    return 'id_' + hash;
  }

  /// The string that identifies our parent (e.g. the package containing a
  /// library, or the class containing a method) or an empty string if
  /// we don't have a parent.
  String get parentQualifiedName =>
      new DocsLocation.fromList(componentNames..removeLast()).withoutAnchor;

  /// The simple name of our parent
  String get parentName {
    var names = componentNames;
    if (names.length < 2) return '';
    return names[names.length - 2];
  }

  toString() => 'DocsLocation($withAnchor)';
}
