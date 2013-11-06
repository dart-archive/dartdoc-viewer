// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library search;

import 'dart:async';
import 'dart:html';
import 'app.dart';
import 'package:dartdoc_viewer/item.dart';
import 'package:dartdoc_viewer/search.dart';
import 'package:dartdoc_viewer/location.dart';
import 'package:polymer/polymer.dart';
import 'results.dart';
import 'member.dart';

/**
 * Component implementing the Dartdoc_viewer search.
 */
@CustomTag("search-box")
class Search extends DartdocElement {

  Search.created() : super.created();

  List<SearchResult> results = [];

  @observable bool isFocused = false;

  String _searchQuery = "";
  @published get searchQuery => _searchQuery;
  @published set searchQuery(newQuery) {
    _searchQuery = newQuery;
    updateResults();
  }

  @observable bool get hasNoResults => results.isEmpty;

  @observable String get dropdownOpen =>
      !searchQuery.isEmpty && isFocused ? 'open' : '';

  int currentIndex = -1;

  void updateResults() {
    currentIndex = -1;
    results.clear();
    results.addAll(lookupSearchResults(
        searchQuery,
        viewer.isDesktop ? 10 : 5,
        locationValidInContext));
    notifyPropertyChange(#results, null, results);
    notifyPropertyChange(#hasNoResults, null, hasNoResults);
    notifyPropertyChange(#dropdownOpen, null, dropdownOpen);
  }

  /// Return true if we consider [location] valid in the current context. This
  /// is used to filter search so that if we're inside a package we will
  /// give search priority to things within that package, or if we're
  /// not showing pkg, we will give lower priority to search results from there.
  bool locationValidInContext(DocsLocation location) {
    var currentContext = viewer.currentPage.home;
    var showPkg = viewer.showPkgLibraries;
    if (currentContext == viewer.homePage) {
      if (viewer.showPkgLibraries) {
        return true;
      } else {
        return location.packageName == null;
      }
    } else {
      return location.packageName == currentContext.name;
    }
  }

  void onBlurCallback(_) {
    isFocused = false;
    notifyPropertyChange(#dropdownOpen, 'open', '');
  }

  void onFocusCallback(_) {
    isFocused = true;
  }

  void onSubmitCallback(event, detail, target) {
    if (!results.isEmpty) {
      String refId;
      if (target != null ) {
        // We get either the li or a element depending if we click or
        // hit enter, so check both.
        refId = target.dataset['ref-id'];
        var parentRefId = target.parent.dataset['ref-id'];
        if (refId == null) refId = parentRefId;
      }
      if (refId == null || refId.isEmpty) {
        // If nothing is focused, use the first search result.
        refId = results.first.element;
      }
      var newLocation = new LinkableType(refId).location;
      var encoded = Uri.encodeFull(newLocation);
      viewer.handleLink(encoded);
      window.history.pushState("#$encoded", viewer.title, "#$encoded");
      searchQuery = "";
      results.clear();
      dartdocMain.searchSubmitted();
    }
  }

  void enteredView() {
    super.enteredView();
    Element.focusEvent.forTarget(xtag, useCapture: true)
        .listen(onFocusCallback);
    Element.blurEvent.forTarget(xtag, useCapture: true)
        .listen(onBlurCallback);
    onKeyDown.listen(handleUpDown);
    window.onKeyDown.listen(shortcutHandler);
  }

  void handleUpDown(KeyboardEvent e) {
    if (e.keyCode == KeyCode.UP) {
      if (currentIndex > 0) {
        currentIndex--;
        shadowRoot.querySelector('#search$currentIndex').parent.focus();
      } else if (currentIndex == 0) {
        searchBox.focus();
      }
      e.preventDefault();
    } else if (e.keyCode == KeyCode.DOWN) {
      if (currentIndex < results.length - 1) {
        currentIndex++;
        shadowRoot.querySelector('#search$currentIndex').parent.focus();
      }
      e.preventDefault();
    } else if (e.keyCode == KeyCode.ENTER) {
      onSubmitCallback(e, null,
          shadowRoot.querySelector('#search$currentIndex'));
      e.preventDefault();
    }
  }

  /** Activate search on Ctrl+3 and S. */
  void shortcutHandler(KeyboardEvent event) {
    if (event.keyCode == KeyCode.THREE && event.ctrlKey) {
      searchBox.focus();
      event.preventDefault();
    } else if (!isFocused && event.keyCode == KeyCode.S) {
      // Allow writing 's' in the search input.
      searchBox.focus();
      event.preventDefault();
    } else if (event.keyCode == KeyCode.ESC) {
      searchQuery = "";
      results.clear();
      event.preventDefault();
    }
  }

  get searchBox => shadowRoot.querySelector('#q');
}