#!/usr/bin/env dart

import 'package:polymer/builder.dart';
import 'dart:io';
import 'package:path/path.dart';

void main(options) {
  lint(entryPoints: ['web/index.html'], options: parseOptions(options))
    .then((_) => deploy(
        entryPoints: ['web/index.html'], 
        options: parseOptions(options))).then(compileToJs);
}

compileToJs(_) {
  print("Running dart2js");
  var dart2js = join(dirname(Platform.executable), 'dart2js');
  var result =
    Process.runSync(dart2js, [ '--minify',
        '-o', 'out/web/index.html_bootstrap.dart.js',
        'out/web/index.html_bootstrap.dart', '--suppress-hints'],
        runInShell: true);
  print(result.stdout);
  print("Done");
}
