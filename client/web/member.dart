library member;

import 'dart:html';

import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/search.dart';
import 'package:web_ui/web_ui.dart';

import 'app.dart' as app;

/// This is a web component to be extended by all Dart members with comments.
/// Each member has an [Item] associated with it as well as a comment to
/// display, so this class handles those two aspects shared by all members.
class MemberElement extends WebComponent {
  @observable Item item;
  
  /// Adds [item]'s comment to the the [elementName] element with markdown
  /// links converted to working links.
  void addComment(String elementName) {
    if (item.comment != '' && item.comment != null) {
      var commentLocation = getShadowRoot(elementName).query('.description');
      commentLocation.children.clear();
      var comment = new Element.html(item.comment);
      var links = comment.queryAll('a');
      for (AnchorElement link in links) {
        if (link.href =='') {
          if (link.text.contains('#')) {
            // If the link is to a parameter of this method, it shouldn't be
            // made into a working link. It instead is replaced with an <i>
            // tag to make it stand out within the comment.
            // TODO(tmandel): Handle parameters differently?
            var index = link.text.indexOf('#');
            var newName = link.text.substring(index + 1, link.text.length);
            link.replaceWith(new Element.html('<i>$newName</i>'));
          } else if (!index.contains(link.text)) {
            // If markdown links to private or otherwise unknown members are
            // found, make them <i> tags instead of <a> tags for CSS.
            link.replaceWith(new Element.html('<i>${link.text}</i>'));
          } else {
            var linkable = new LinkableType(link.text);
            link
              ..onClick.listen((_) => app.viewer.handleLink(linkable.location))
              ..text = linkable.simpleType;
          }
        }
      }
      commentLocation.children.add(comment);
    }
  }
  
  /// Creates an HTML element for a parameterized type.  
  static Element createInner(NestedType type) {
    var span = new SpanElement();
    if (!index.contains(type.outer.simpleType)) {
      var outer = new AnchorElement()
        ..text = type.outer.simpleType
        ..onClick.listen((_) => app.viewer.handleLink(type.outer.location));
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
    var location = getShadowRoot(memberName).query('.$className');
    location.children.clear();
    location.children.add(createInner(type));
  }
}