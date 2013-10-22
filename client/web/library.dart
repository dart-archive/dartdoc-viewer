library library;

import 'dart:async';

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-library")
class LibraryElement extends MemberElement {
  LibraryElement.created() : super.created();

  get observables => concat(super.observables,
      const [#operators, #variables, #functions, #classes,
      #typedefs, #errors, #operatorsIsNotEmpty, #variablesIsNotEmpty,
      #functionsIsNotEmpty, #classesIsNotEmpty, #typedefsIsNotEmpty,
      #errorsIsNotEmpty]);
  wrongClass(newItem) => newItem is! Library;

  get item => super.item;
  set item(newItem) => super.item = newItem;

  @observable get operators =>
     item.operators == null ? [] : item.operators.content;
  @observable get variables =>
     item.variables == null ? [] : item.variables.content;
  @observable get functions =>
     item.functions == null ? [] : item.functions.content;
  @observable get classes => item.classes == null ? [] : item.classes.content;
  @observable get typedefs =>
      item.typedefs == null ? [] : item.typedefs.content;
  @observable get errors => item.errors == null ? [] : item.errors.content;

  @observable get operatorsIsNotEmpty => operators.isNotEmpty;
  @observable get variablesIsNotEmpty => variables.isNotEmpty;
  @observable get functionsIsNotEmpty => functions.isNotEmpty;
  @observable get classesIsNotEmpty => classes.isNotEmpty;
  @observable get typedefsIsNotEmpty => typedefs.isNotEmpty;
  @observable get errorsIsNotEmpty => errors.isNotEmpty;

  get defaultItem => new Library.forPlaceholder({
      "name" : 'loading',
      "preview" : 'loading',
    });
}
