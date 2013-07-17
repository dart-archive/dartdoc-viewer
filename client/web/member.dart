import 'dart:html';

import 'package:dartdoc_viewer/item.dart';
import 'package:web_ui/web_ui.dart';

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