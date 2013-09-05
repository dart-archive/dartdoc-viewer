library index;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'member.dart';
import 'app.dart' as app;
import 'dart:html';

@CustomTag("dartdoc-main")
class IndexElement extends DartdocElement {

  IndexElement() {
    new PathObserver(this, "viewer.currentPage").bindSync(
        (_) {
          notifyProperty(this, #viewer);
          notifyProperty(this, #shouldShowLibraryMinimap);
          notifyProperty(this, #shouldShowClassMinimap);
          notifyProperty(this, #crumbs);
          notifyProperty(this, #pageContentClass);
        });
    new PathObserver(this, "viewer.isMinimap").bindSync(
      (_) {
        notifyProperty(this, #shouldShowLibraryMinimap);
        notifyProperty(this, #shouldShowClassMinimap);
        notifyProperty(this, #pageContentClass);
      });
    new PathObserver(this, "viewer.isPanel").bindSync(
      (_) {
        notifyProperty(this, #pageContentClass);
        notifyProperty(this, #shouldShowLibraryMinimap);
        notifyProperty(this, #shouldShowClassMinimap);
      });
  }

  @observable get pageContentClass {
    if (!viewer.isDesktop) return '';
    var left = viewer.isPanel ? 'margin-left ' : '';
    var right = viewer.isMinimap ? 'margin-right' : '';
    return left + right;
  }

  query(String selectors) => shadowRoot.query(selectors);

  searchSubmitted() {
    query('#nav-collapse-button').classes.add('collapsed');
    query('#nav-collapse-content').classes.remove('in');
    query('#nav-collapse-content').classes.add('collapse');
  }

  @observable get item => viewer.currentPage.item;
  @observable get pageNameSeparator => decoratedName == '' ? '' : ' - ';
  @observable get decoratedName =>
      viewer.currentPage == null ? '' : viewer.currentPage.decoratedName;
  togglePanel(event, detail, target) => viewer.togglePanel();
  toggleInherited(event, detail, target) => viewer.toggleInherited();
  toggleMinimap(event, detail, target) => viewer.toggleMinimap();

  @observable get shouldShowLibraryMinimap =>
      viewer.currentPage is Library && viewer.isMinimap;

  get shouldShowClassMinimap => viewer.currentPage is Class && viewer.isMinimap;

  get breadcrumbs => viewer.breadcrumbs;

  /// Add the breadcrumbs programmatically.
  @observable crumbs() {
    var root = shadowRoot.query("#navbar");
    if (root == null) return;
    root.children.clear();
    if (breadcrumbs.length < 2) return;
    var last = breadcrumbs.toList().removeLast();
    breadcrumbs.skip(1).takeWhile((x) => x != last).forEach(
        (x) => root.append(normalCrumb(x)));
    root.append(finalCrumb(last));
  }

  normalCrumb(item) =>
      new Element.html('<li><a class="btn-link" '
        'href="#${item.linkHref}">'
        '${item.decoratedName}</a></li>',
        treeSanitizer: sanitizer);

  finalCrumb(item) =>
    new Element.html('<li class="active"><a class="btn-link">'
      '${item.decoratedName}</a></li>',
      treeSanitizer: sanitizer);

  hideShowOptions(event, detail, target) {
    var list = shadowRoot.query(".dropdown-menu").parent;
    if (list.classes.contains("open")) {
      list.classes.remove("open");
    } else {
      list.classes.add("open");
    }
  }

}