import 'dart:html';

import 'package:dartdoc_viewer/item.dart';
import 'package:web_ui/web_ui.dart';

import 'app.dart' as app;

/// This is a web component to be extended by all Dart members with comments.
/// Each member has an [Item] associated with it as well as a comment to
/// display, so this class handles those two aspects shared by all members.
class MemberElement extends WebComponent {
  @observable Item item;
  
  void addComment(String elementName) {
    if (item.comment != '' && item.comment != null) {
      var commentLocation = getShadowRoot(elementName).query('.description');
      commentLocation.children.clear();
      var comment = new Element.html(item.comment);
      var links = comment.queryAll('a');
      for (AnchorElement link in links) {
        // TODO(tmandel): Also check that there are no on-click handlers. Since
        // link.onClick.isEmpty is a Future, it is hard to check each and then
        // add them all to [commentLocation].
        if (link.href =='') {
          if (link.text.contains('#')) {
            // TODO(tmandel): Handle parameters differently?
            var index = link.text.indexOf('#');
            var newName = link.text.substring(index + 1, link.text.length);
            link.replaceWith(new Element.html('<i>$newName</i>'));
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
}