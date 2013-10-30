// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library annotations;

import 'package:dartdoc_viewer/item.dart';
import 'package:polymer/polymer.dart';
import 'app.dart';
import 'member.dart';

@CustomTag("dartdoc-annotation")
class AnnotationElement extends DartdocElement {
  AnnotationElement.created() : super.created();

  get methodsToCall => concat(super.methodsToCall, const [#addAnnotations]);
  AnnotationGroup _annotations;
  @published get annotations => _annotations;
  @published set annotations(newAnnotations) {
    notifyObservables(() => _annotations = newAnnotations);
  }

  void addAnnotations() {
    shadowRoot.children.clear();
    if (annotations == null || annotations.annotations.isEmpty) return;
    var out = new StringBuffer();
    for (var annotation in annotations.annotations) {
      out.write('<i><a href="#${annotation.link.location}">'
          '${annotation.link.simpleType}</a></i>');
      var hasParams = annotation.parameters.isNotEmpty;
      if (hasParams) out.write("(");
      out.write(annotation.parameters.join(",&nbsp;"));
      if (hasParams) out.write(")");
    }
    if (annotations.supportedBrowsers.isNotEmpty) {
      out.write("<br/><i>Supported on: ");
      out.write(annotations.supportedBrowsers.join(",&nbsp;"));
      out.write("</i><br/>");
    }
    var fragment = createFragment(out.toString(), treeSanitizer: sanitizer);
    shadowRoot.append(fragment);
  }
}