// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library minimap_element;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart' as app;
import 'member.dart';
import 'package:dartdoc_viewer/location.dart';

/// An element in a page's minimap displayed on the right of the page.
@CustomTag("dartdoc-minimap")
class MinimapElement extends DartdocElement {
  MinimapElement.created() : super.created() {
    new PathObserver(this, "viewer.isInherited").bindSync(
      (_) {
        notifyPropertyChange(#itemsToShow, null, itemsToShow);
      });
  }

  List<Item> _items = [];
  @published List<Item> get items => _items;
  @published set items(newItems) {
    notifyObservables(() => _items = newItems);
  }

  get observables => concat(super.observables, const [#itemsToShow]);

  @observable get itemsToShow => items.where(
      (item) => !item.isInherited || viewer.isInherited);

  /// Creates a proper href String for an [Item].
  @observable String link(linkItem) {
   var hash = linkItem.name == '' ? linkItem.decoratedName : linkItem.name;
   return '${viewer.currentPage.linkHref}'
       '#${new DocsLocation.empty().toHash(hash)}';
  }
}