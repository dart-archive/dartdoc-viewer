import 'dart:html';

import 'package:dartdoc_viewer/item.dart';
import 'package:web_ui/web_ui.dart';

/// This is a web component to be extended by all Dart members with comments.
/// Each member has an [Item] associated with it as well as a comment to
/// display, so this class handles those two aspects shared by all members.
class MemberElement extends WebComponent {
  @observable Item item;
  
  void addComment(String elementName) {
    if (item.comment != '' && item.comment != null) {
      var comment = getShadowRoot(elementName).query('.description');
      comment.children.clear();
      comment.children.add(new Element.html(item.comment));
    }
  }
}