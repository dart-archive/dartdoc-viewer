library index;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'member.dart';
import 'app.dart' as app;
import 'dart:html';

@CustomTag("dartdoc-main")
class IndexElement extends DartdocElement {

  IndexElement.created() : super.created();

  enteredView() {
    super.enteredView();
    new PathObserver(this, "viewer.currentPage").bindSync(
      (_) {
        notifyPropertyChange(#shouldShowLibraryMinimap,
            null, shouldShowLibraryMinimap);
        notifyPropertyChange(#shouldShowClassMinimap, null,
            shouldShowClassMinimap);
        notifyPropertyChange(#crumbs, null, 'some value');
        notifyPropertyChange(#pageContentClass, null, pageContentClass);
        notifyPropertyChange(#isHomePage, null, isHomePage);
      });
    new PathObserver(this, "viewer.isMinimap").changes.listen((changes) {
      notifyPropertyChange(#shouldShowLibraryMinimap,
          shouldShowLibraryMinimapFor(changes.first.oldValue),
          shouldShowLibraryMinimap);
      notifyPropertyChange(#shouldShowClassMinimap,
          shouldShowClassMinimapFor(changes.first.oldValue),
          shouldShowClassMinimap);
      notifyPropertyChange(#pageContentClass,
          null,
          pageContentClass);
    });
    new PathObserver(this, "viewer.isPanel").bindSync(
      (_) {
        notifyPropertyChange(#pageContentClass, null, pageContentClass);
      });
  }

  @observable get pageContentClass {
    if (!viewer.isDesktop) return '';
    var left = viewer.isPanel ? 'margin-left ' : '';
    var right = viewer.isMinimap ? 'margin-right' : '';
    return left + right;
  }

  query(String selectors) => shadowRoot.querySelector(selectors);

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
      shouldShowLibraryMinimapFor(viewer.isMinimap);
  shouldShowLibraryMinimapFor(isMinimap) =>
      viewer.currentPage is Library && isMinimap;

  @observable get shouldShowClassMinimap =>
      shouldShowClassMinimapFor(viewer.isMinimap);
  @observable shouldShowClassMinimapFor(isMinimap) =>
      viewer.currentPage is Class && isMinimap;
  @observable get isHomePage => viewer.currentPage == viewer.homePage;
  @observable get homePage => viewer.homePage;
  set homePage(x) {}
  @observable get viewer => super.viewer;

  get breadcrumbs => viewer.breadcrumbs;

  /// Add the breadcrumbs programmatically.
  @observable void crumbs() {
    var root = shadowRoot.querySelector("#navbar");
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
    var list = shadowRoot.querySelector(".dropdown-menu").parent;
    if (list.classes.contains("open")) {
      list.classes.remove("open");
    } else {
      list.classes.add("open");
    }
  }
}