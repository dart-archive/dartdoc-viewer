// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library page;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/item.dart';
import 'app.dart' as app;
import 'member.dart';

/**
 * An HTML representation of a page
 */
@CustomTag("dartdoc-page")
class PageElement extends DartdocElement {
  @observable Home home;

  PageElement.created() : super.created();

  enteredView() {
    super.enteredView();
    new PathObserver(this, "viewer.currentPage").changes.listen((changes) {
      var change = changes.first;
      notifyPropertyChange(#currentPage, change.oldValue, change.newValue);
      notifyPropertyChange(#currentPageIsLibrary,
          change.oldValue is Library,
          change.newValue is Library);
      notifyPropertyChange(#currentPageIsMethod,
          change.oldValue is Method,
          change.newValue is Method);
      notifyPropertyChange(#currentPageIsClass,
          change.oldValue is Class,
          change.newValue is Class);
      notifyPropertyChange(#currentPageIsTypedef,
          change.oldValue is Typedef,
          change.newValue is Typedef);
      notifyPropertyChange(#isHome,
          change.oldValue is Home,
          change.newValue is Home);
    });
    new PathObserver(this, "viewer.homePage").bindSync(
        (_) {
          notifyPropertyChange(#hasHomePage, null, hasHomePage);
          notifyPropertyChange(#homePage, null, homePage);
          notifyPropertyChange(#isHome, null, isHome);
    });
    style.setProperty('display', 'block');
  }

  @observable get homePage => viewer.homePage;
  @observable get isHome => currentPage is Home;
  @observable get hasHomePage => viewer.homePage != null;

  @observable get currentPageIsLibrary => currentPage is Library;
  @observable get currentPageIsMethod => currentPage is Method;
  @observable get currentPageIsClass => currentPage is Class;
  @observable get currentPageIsTypedef => currentPage is Typedef;

  @observable get currentPage => viewer.currentPage;
  set currentPage(x) {}
}