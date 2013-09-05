library library_panel;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart' as app;
import 'member.dart';
import 'dart:html';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-library-panel")
class LibraryPanel extends DartdocElement {
  LibraryPanel() {
    new PathObserver(this, "viewer.currentPage").bindSync(
    (_) {
      notifyProperty(this, #createEntries);
    });
  }

  linkHref(library) => library == null ? '' : library.linkHref;

  @observable createEntries() {
    var mainElement = shadowRoot.query("#library-panel");
    if (mainElement == null) return;
    // TODO(alanknight): Can we get away with checking if the children
    // have been added at all, so we don't have to re-do it every time.
    mainElement.children.clear();
    for (var library in viewer.homePage.libraries) {
      var isFirst =
          library.decoratedName == viewer.breadcrumbs.first.decoratedName;
      var element =
          isFirst ? newElement(library, true) : newElement(library, false);
      mainElement.append(element);
    }
  }

  newElement(Library library, bool isActive) {
    var html = '<a href="#${linkHref(library)}" class="list-group-item'
        '${isActive ? ' active' : ''}">'
        '${library.decoratedName}</a>';
    return new Element.html(html, treeSanitizer: sanitizer);
  }
}