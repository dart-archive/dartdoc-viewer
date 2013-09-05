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

  PageElement() {
    new PathObserver(this, "viewer.currentPage").bindSync(
        (_) {
          notifyProperty(this, #currentPage);
          notifyProperty(this, #currentPageIsLibrary);
          notifyProperty(this, #currentPageIsMethod);
          notifyProperty(this, #currentPageIsClass);
          notifyProperty(this, #currentPageIsTypedef);
          notifyProperty(this, #isHome);
          notifyProperty(this, #hasHomePage);
        });
    new PathObserver(this, "viewer.homePage").bindSync(
        (_) {
          notifyProperty(this, #hasHomePage);
        });
  }

  @observable get isHome => currentPage is Home;
  @observable get hasHomePage => viewer.homePage != null;

  @observable get currentPageIsLibrary => currentPage is Library;
  @observable get currentPageIsMethod => currentPage is Method;
  @observable get currentPageIsClass => currentPage is Class;
  @observable get currentPageIsTypedef => currentPage is Typedef;

  @observable get currentPage => viewer.currentPage;
  set currentPage(x) {}
}