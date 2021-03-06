// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library web.search;

import 'dart:async';
import 'dart:html';
import 'package:dartdoc_viewer/app.dart';
import 'package:dartdoc_viewer/shared.dart';
import 'package:dartdoc_viewer/search.dart';
import 'package:dartdoc_viewer/location.dart';
import 'package:dartdoc_viewer/member.dart';
import 'package:polymer/polymer.dart';

/**
 * Component implementing the Dartdoc_viewer search.
 */
@CustomTag("search-box")
class Search extends PolymerElement {
  @published String searchQuery = '';

  @observable bool isFocused = false;
  @observable ObservableList<SearchResult> results = toObservable([]);
  @observable String dropdownOpen;
  int currentIndex = -1;

  Search.created() : super.created();

  get syntax => defaultSyntax;
  bool get applyAuthorStyles => true;

  void searchQueryChanged() {
    currentIndex = -1;
    results.clear();
    results.addAll(lookupSearchResults(
        searchIndex,
        searchQuery,
        viewer.isDesktop ? 10 : 5,
        locationValidInContext));

    _updateDropdownOpen();
  }

  void _updateDropdownOpen() {
    dropdownOpen = !searchQuery.isEmpty && isFocused ? 'open' : '';
  }

  /// Return true if we consider [location] valid in the current context. This
  /// is used to filter search so that if we're inside a package we will
  /// give search priority to things within that package, or if we're
  /// not showing pkg, we will give lower priority to search results from there.
  bool locationValidInContext(DocsLocation location) => true;

  void onBlurCallback(_) {
    isFocused = false;
    new Future.value(null).then((_) => _updateDropdownOpen());
  }

  void onFocusCallback(_) {
    isFocused = true;
  }

  /// Find the first ref-id data attribute on a parent of [element].
  String _searchRefId(element) {
    if (element == null) return null;
    if (element is Element && element.dataset['ref-id'] != null) {
      return element.dataset['ref-id'];
    }
    if (element is ShadowRoot) return _searchRefId(element.host);
    return _searchRefId(element.parentNode);
  }

  void selectDropDownItem(event, detail, target) {
    if (results.isEmpty) return;
    // event.target is within [results.html] template. As we walk up, we find
    // the <a is='search-result'> element which contains the dataset
    // information.
    var refId = _searchRefId(event.target);
    if (refId != null) _navigateTo(refId);
  }

  void _navigateTo(String refId) {
    // Technically this shouldn't happen, but just in case.
    if (refId == null || refId.isEmpty) return;
    var newLocation = new DocsLocation(refId).withAnchor;
    var encoded = Uri.encodeFull(newLocation);
    viewer.handleLink(encoded, useHistory);
    if (useHistory) {
      window.history.pushState(locationPrefixed(encoded),
          viewer.title, locationPrefixed(encoded));
    }
    searchQuery = "";
    results.clear();
  }

  void attached() {
    super.attached();

    registerNamedObserver('onfocus', Element.focusEvent
        .forTarget(this, useCapture: true).listen(onFocusCallback));

    registerNamedObserver('onblur',  Element.blurEvent
        .forTarget(this, useCapture: true).listen(onBlurCallback));
    registerNamedObserver('onkeydown', onKeyDown.listen(handleUpDown));
    registerNamedObserver('window.onkeydown',
        window.onKeyDown.listen(shortcutHandler));
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
      // If nothing is focused, use the first search result.
      if (results.isNotEmpty) {
        _navigateTo(results[currentIndex == -1 ? 0 : currentIndex].url);
      }
      e.preventDefault();
    }
  }

  /** Activate search on Ctrl+3, /, and S. */
  void shortcutHandler(KeyboardEvent event) {
    if (event.keyCode == KeyCode.THREE && event.ctrlKey) {
      searchBox.focus();
      event.preventDefault();
    } else if (!isFocused &&
        (event.keyCode == KeyCode.S || event.keyCode == KeyCode.SLASH)) {
      // Allow writing 's' and '/' in the search input.
      searchBox.focus();
      searchBox.select();
      event.preventDefault();
    } else if (event.keyCode == KeyCode.ESC) {
      searchQuery = "";
      searchBox.value = '';
      event.preventDefault();
    }
  }

  InputElement get searchBox => shadowRoot.querySelector('#q');

  /// This is called from the template, so needs to be available
  /// as an instance method.
  void rerouteLink(event, detail, target) => routeLink(event, detail, target);
}
