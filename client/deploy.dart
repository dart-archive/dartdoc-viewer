#!/usr/bin/env dart

import 'package:polymer/builder.dart';
import 'dart:io';

void main(options) {
  build(entryPoints: ['web/index.html'], options: parseOptions(['--deploy']))
      .then(compileToJs);
}

compileToJs(_) {
  print("Running dart2js");
  var dart2js = '${Platform.executable}2js';
  var result =
    Process.runSync(dart2js, [ '--minify',
        '-o', 'out/web/index.html_bootstrap.dart.js',
        'out/web/index.html_bootstrap.dart', '--suppress-hints'],
        runInShell: true);
  print(result.stdout);
  print("Done");
}
