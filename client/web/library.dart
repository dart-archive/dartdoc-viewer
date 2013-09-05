library library;

import 'dart:async';

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-library")
class LibraryElement extends MemberElement {
  LibraryElement() {
    item = defaultItem;
  }

  get item => super.item;
  set item(newItem) => super.item = newItem is Library ? newItem : defaultItem;

  get defaultItem => item = new Library.forPlaceholder({
      "name" : 'loading',
      "preview" : 'loading',
    });
}
