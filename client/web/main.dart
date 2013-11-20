// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library index;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'member.dart';
import 'app.dart';
import 'dart:html';
import 'package:dartdoc_viewer/read_yaml.dart';

// TODO(alanknight): Clean up the dart-style CSS file's formatting once
// it's stable.
@CustomTag("dartdoc-main")
class IndexElement extends DartdocElement {

  /// Records the timestamp of the event that opened the options menu.
  var _openedAt;

  /// Remember where we think the top of the main body normally ought to be.
  String originalPadding;

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
    onClick.listen(hideOptionsMenuWhenClickedOutside);
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
  togglePkg(event, detail, target) => viewer.togglePkg();

  @observable get shouldShowLibraryMinimap =>
      shouldShowLibraryMinimapFor(viewer.isMinimap);
  shouldShowLibraryMinimapFor(isMinimap) =>
      viewer.currentPage is Library && isMinimap;

  @observable get shouldShowClassMinimap =>
      shouldShowClassMinimapFor(viewer.isMinimap);
  @observable shouldShowClassMinimapFor(isMinimap) =>
      viewer.currentPage is Class && isMinimap;
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
        validator: validator);

  finalCrumb(item) =>
    new Element.html('<li class="active"><a class="btn-link">'
      '${item.decoratedName}</a></li>',
      validator: validator);

  void toggleOptionsMenu(MouseEvent event, detail, target) {
    var list = shadowRoot.querySelector(".dropdown-menu").parent;
    if (list.classes.contains("open")) {
      list.classes.remove("open");
    } else {
      _openedAt = event.timeStamp;
      list.classes.add("open");
    }
  }

  void hideOptionsMenuWhenClickedOutside(MouseEvent e) {
    if (_openedAt != null && _openedAt == e.timeStamp) {
      _openedAt == null;
      return;
    }
    hideOptionsMenu();
  }

  void hideOptionsMenu() {
    var list = shadowRoot.querySelector(".dropdown-menu").parent;
    list.classes.remove("open");
  }

  var _buildIdentifier;
  @observable get buildIdentifier {
    if (_buildIdentifier == null) {
      _buildIdentifier = ''; // Don't try twice.
      retrieveFileContents('docs/VERSION').then((version) {
        _buildIdentifier = "r $version";
        notifyPropertyChange(#buildIdentifier, null, _buildIdentifier);
      }).catchError((_) => null);
      return '';
    } else {
      return _buildIdentifier;
    }
  }

  /// Collapse/expand the navbar when in mobile. Workaround for something
  /// that ought to happen magically with bootstrap, but fails in the
  /// presence of shadow DOM.
  @observable navHideShow(event, detail, target) {
    var nav = shadowRoot.querySelector("#nav-collapse-content");
    hideOrShowNavigation(hide: nav.classes.contains("in"), nav: nav);
  }

  @observable hideOrShowNavigation({bool hide, Element nav}) {
    if (nav == null) nav = shadowRoot.querySelector("#nav-collapse-content");
    if (hide) {
      nav.classes.remove("in");
    } else {
      nav.classes.add("in");
    }
    // The navbar is fixed, but can change size. We need to tell the main
    // body to be below the expanding navbar. This seems to be the least
    // horrible way to do that. But this will only work on the current page,
    // so if we change pages we have to make sure we close this.
    var navbar = shadowRoot.querySelector(".navbar-nav");
    Element body = shadowRoot.querySelector(".main-body");
    var rects = navbar.getClientRects();
    if (rects.isEmpty) {
      if (originalPadding != null) body.style.paddingTop = originalPadding;
    } else {
      originalPadding = body.style.paddingTop;
      body.style.paddingTop = (rects.first.height).toString() + "px";
    }
  }
}
