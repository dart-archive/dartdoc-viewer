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
import 'dart:math';

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
    var crumbs = breadcrumbs.skip(1).takeWhile((x) => x != last).
        map(normalCrumb).toList();
    crumbs.forEach(root.append);
    root.append(finalCrumb(last));
    collapseSearchAndOptionsIfNeeded();
  }

  /// We want the search and options to collapse into a menu button if there
  /// isn't room for them to fit, but the amount of room taken up by the
  /// breadcrumbs is dynamic, so we calculate the widths programmatically
  /// and set the collapse style if necessary. As a bonus, when we're expanding
  /// we have to make them visible first in order to measure the width to know
  /// if we should leave them visible or not.
  void collapseSearchAndOptionsIfNeeded() {
    // TODO(alanknight) : This is messy because we've deleted many of the
    // bootstrap-specific attributes, but we need some of it in order to have
    // things look right. This leads to the odd behavior where the drop-down
    // makes the crumbs appear either in the title bar or dropping down,
    // depending how wide the window is. I'm calling that a feature for now,
    // but it could still use cleanup.
    var permanentHeaders = shadowRoot.querySelectorAll(".navbar-brand");
    var searchAndOptions = shadowRoot.querySelector("#searchAndOptions");
    var wholeThing = shadowRoot.querySelector(".navbar-fixed-top");
    var navbar = shadowRoot.querySelector("#navbar");
    var collapsible = shadowRoot.querySelector("#nav-collapse-content");
    // First, we make it visible, so we can see how large it _would_ be.
    collapsible.classes.add("in");
    var allItems = permanentHeaders.toList()
      ..add(searchAndOptions)
      ..add(navbar);
    var innerWidth = allItems.fold(0,
        (sum, element) => sum + element.marginEdge.width);
    var outerWidth = wholeThing.contentEdge.width;
    var button = shadowRoot.querySelector("#nav-collapse-button");
    // Then if it's too big, we make it go away again.
    if (outerWidth <= innerWidth) {
      button.classes.add("visible");
      collapsible.classes.remove("in");
    } else {
      button.classes.remove("visible");
      collapsible.classes.add("in");
    }
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

  @observable hideOrShowNavigation({bool hide : true, Element nav}) {
    if (nav == null) nav = shadowRoot.querySelector("#nav-collapse-content");
    var button = shadowRoot.querySelector("#nav-collapse-button");
    if (hide && button.getComputedStyle().display != 'none') {
      nav.classes.remove("in");
    } else {
      nav.classes.add("in");
    }
    // The navbar is fixed, but can change size. We need to tell the main
    // body to be below the expanding navbar. This seems to be the least
    // horrible way to do that. But this will only work on the current page,
    // so if we change pages we have to make sure we close this.
    var navbar = shadowRoot.querySelector(".navbar-fixed-top");
    Element body = shadowRoot.querySelector(".main-body");
    var height = navbar.marginEdge.height;
    var positioning = navbar.getComputedStyle().position;
    if (positioning == "fixed") {
      body.style.paddingTop = height.toString() + "px";
    } else {
      body.style.removeProperty("padding-top");
    }
  }
}