// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library url_parsing_test;

import 'package:unittest/unittest.dart';
import 'package:dartdoc_viewer/location.dart';

// Intent is to match
// package/library-name.libMember.subMember#anchor
// or  library-name.libMember.subMember#anchor
// where everything except library is optional, but you can't have
// a sub-member without a member.

// Mapping from URI to list of the form
// [package, library, class, member, anchor]
var urls = {
  "dart-core" : [null, "dart-core", null, null, null ],
  "dart-core.Object" : [null, "dart-core", "Object", null, null],
//  "dart-core.Object.=="
  "dart-core.Object.toString" : [null, "dart-core", "Object", "toString", null],
  "intl" : [null, "intl", null, null, null],
  "intl/intl" : ["intl", "intl", null, null, null],
  "intl/intl.Intl" : ["intl", "intl", "Intl", null, null],
  "intl/intl.Intl@id_foo" : ["intl", "intl", "Intl", null, "id_foo"],
  "intl/intl.Intl.message" : ["intl", "intl", "Intl", "message", null],
  "intl@id_foo" : [null, "intl", null, null, "id_foo"],
  "dart-async.Future@id_then,onError" :
      [null, "dart-async", "Future", null, "id_then,onError"],
  "dart-core.List.List-filled.value" :
    [null, "dart-core", "List", "List-filled", "value"],
};

// Convert the map results to a list that's easier to write the expected
// form literally.
_asList(Map m) => [m['package'], m['library'], m['member'], m['subMember'],
                   m['anchor']];

main() {
  urls.forEach((uri, result) {
    test("test parsing $uri", () {
      var location = new DocsLocation(uri);
      expect(location.allComponentNames, result);
    });

    test("Converting hashes", () {
      var basic = "dart-async.Future@id_then,onError";
      var constructor = "dart-async.Future@id_Future-delayed";
      var constructorParam = "dart-async.Future@id_Future-delayed,duration";
      var unnamedConstructor = "dart-async.Future@id_Future-";
      var unnamedConstructorParam = "dart-async.Future@id_Future-,computation";
      var basic1 = "dart-async.Future.then@onError";
      var constructor1 = "dart-async.Future.Future-delayed";
      var constructorParam1 = "dart-async.Future.Future-delayed@duration";
      var unnamedConstructor1 = "dart-async.Future.Future-";
      var unnamedConstructorParam1 = "dart-async.Future.Future-@computation";
      var hashForm = [basic, constructor, constructorParam, unnamedConstructor,
          unnamedConstructorParam];
      var fullForm = [basic1, constructor1, constructorParam1,
          unnamedConstructor1, unnamedConstructorParam1];
      var forms = new Map.fromIterables(hashForm, fullForm);
      forms.forEach((hashed, full) {
        var converted = new DocsLocation(hashed).asMemberOrSubMemberNotAnchor;
        var fullLocation = new DocsLocation(full);
        expect(converted, fullLocation);
      });
    });
  });
}
