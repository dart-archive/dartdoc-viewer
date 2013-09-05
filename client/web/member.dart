library member;

import 'dart:html';

import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/search.dart';
import 'package:polymer/polymer.dart';

import 'app.dart' as app;

class SameProtocolUriPolicy implements UriPolicy {
  final AnchorElement _hiddenAnchor = new AnchorElement();
  final Location _loc = window.location;

  bool allowsUri(String uri) {
    _hiddenAnchor.href = uri;
    // IE leaves an empty protocol for same-origin URIs.
    var older = _hiddenAnchor.protocol;
    var newer = _loc.protocol;
    if ((older == "http:" && newer == "https:")
        || (older == "https:" && newer == "http:")) {
      return true;
    }
    return (older == newer || older == ':');
  }
}

var uriPolicy = new SameProtocolUriPolicy();
var validator = new NodeValidatorBuilder()
    ..allowHtml5(uriPolicy: uriPolicy);

var sanitizer = new NullTreeSanitizer();

// TODO(alanknight): Switch to using the validator, verify it doesn't slow
// things down too much, and that it's not disallowing valid content.
/// A sanitizer that allows anything to maximize speed and not disallow any
/// tags.
class NullTreeSanitizer implements NodeTreeSanitizer {
  void sanitizeTree(Node node) {}
}

//// An abstract class for all Dartdoc elements.
class DartdocElement extends PolymerElement {
  get applyAuthorStyles => true;

  get viewer => app.viewer;
}

//// This is a web component to be extended by all Dart members with comments.
//// Each member has an [Item] associated with it as well as a comment to
//// display, so this class handles those two aspects shared by all members.
class MemberElement extends DartdocElement {
  MemberElement() {
    new PathObserver(this, "item").bindSync(
        (_) {
          notifyProperty(this, #addComment);
        });
  }

  @observable @published var item;

  /// A valid string for an HTML id made from this [Item]'s name.
  @observable String get idName {
    if (item == null) return '';
    var name = item.name;
    if (item.name == '') name = item.decoratedName;
    return app.viewer.toHash(name);
  }

  /// Adds [item]'s comment to the the [elementName] element with markdown
  /// links converted to working links.
  void addComment(String elementName, [bool preview = false]) {
    if (item == null) return;
    var comment = item.comment;
    var commentLocation = shadowRoot.query('.description');
    if (preview && (item is Class || item is Library))
      comment = item.previewComment;
    if (preview && (item is Method || item is Variable)) {
      var index = item.comment.indexOf('</p>');
      // All comments when read in from the YAML is surrounded by a <span> tag.
      // This finds the first paragraph, and surrounds it with a span tag for
      // use as the snippet.
      if (index == -1) comment = '<span></span>';
      else comment = item.comment.substring(0, index) + '</p></span>';
    }
    if (comment != '' && comment != null) {
      if (commentLocation == null) {
        commentLocation = shadowRoot.query('.description');
      }
      commentLocation.children.clear();
      var commentElement = new Element.html(comment,
          treeSanitizer: sanitizer);
      var links = commentElement.queryAll('a');
      for (AnchorElement link in links) {
        if (link.href =='') {
          if (link.text.contains('#')) {
            // If the link is to a parameter of this method, it shouldn't be
            // made into a working link. It instead is replaced with an <i>
            // tag to make it stand out within the comment.
            // TODO(tmandel): Handle parameters differently?
            var index = link.text.indexOf('#');
            var newName = link.text.substring(index + 1, link.text.length);
            link.replaceWith(new Element.html('<i>$newName</i>',
                treeSanitizer: sanitizer));
          } else if (!index.keys.contains(link.text)) {
            // If markdown links to private or otherwise unknown members are
            // found, make them <i> tags instead of <a> tags for CSS.
            link.replaceWith(new Element.html('<i>${link.text}</i>',
                treeSanitizer: sanitizer));
          } else {
            var linkable = new LinkableType(link.text);
            link
              ..href = '#${linkable.location}'
              ..text = linkable.simpleType;
          }
        }
      }
      commentLocation.children.add(commentElement);
    }
  }

  /// Creates an HTML element for a parameterized type.
  static Element createInner(NestedType type) {
    var span = new SpanElement();
    if (index.keys.contains(type.outer.qualifiedName)) {
      var outer = new AnchorElement()
        ..text = type.outer.simpleType
        ..href = '#${type.outer.location}';
      span.append(outer);
    } else {
      span.appendText(type.outer.simpleType);
    }
    if (type.inner.isNotEmpty) {
      span.appendText('<');
      type.inner.forEach((element) {
        span.append(createInner(element));
        if (element != type.inner.last) span.appendText(', ');
      });
      span.appendText('>');
    }
    return span;
  }

  /// Creates a new HTML element describing a possibly parameterized type
  /// and adds it to [memberName]'s tag with class [className].
  void createType(NestedType type, String memberName, String className) {
    if (type == null) return;
    var location = shadowRoot.query('.$className');
    if (location == null) return;
    location.children.clear();
    if (!type.isDynamic) {
      location.children.add(createInner(type));
    }
  }
}

//// A [MemberElement] that could be inherited from another [MemberElement].
class InheritedElement extends MemberElement {
  LinkableType inheritedFrom;
  LinkableType commentFrom;

  inserted() {
    if (isInherited) {
      inheritedFrom = findInheritance(item.inheritedFrom);
    }
    if (hasInheritedComment) {
      commentFrom = findInheritance(item.commentFrom);
    }
  }

  bool get isInherited =>
      item != null && item.inheritedFrom != '' && item.inheritedFrom != null;

  bool get hasInheritedComment =>
      item != null && item.commentFrom != '' && item.commentFrom != null;

  /// Returns whether [location] exists within the search index.
  bool exists(String location) {
    return index.keys.contains(location.replaceAll('-','.'));
  }

  /// Creates a [LinkableType] for the owner of [qualifiedName].
  LinkableType findInheritance(String qualifiedName) {
    return new LinkableType(ownerName(qualifiedName));
  }
}

class MethodElement extends InheritedElement {
  MethodElement() {
    item = new Method({
      "name" : "Loading",
      "qualifiedName" : "Loading",
      "comment" : "",
      "parameters" : null,
      "return" : [null],
    }, isConstructor: true);
  }

  // TODO(alanknight): Remove this and other workarounds for bindings firing
  // even when their surrounding test isn't true. This ignores values of the
  // wrong type. IOssue 13386 and/or 13445
  // TODO(alanknight): Remove duplicated subclass methods. Issue 13937
  set item(newItem) => super.item = (newItem is Method) ? newItem : item;
  Method get item => super.item;

  @observable List<Parameter> get parameters => item.parameters;
}
