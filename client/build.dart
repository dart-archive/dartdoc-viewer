#!/usr/bin/env dart

import 'package:polymer/builder.dart';

void main(options) {
  lint(entryPoints: ['web/index.html'], options: parseOptions(options));
}
