#!/bin/bash
# Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Usage: call directly in the command line as test/run.sh with 'content_shell' 
# in your path. This script runs all tests for the dartdoc viewer.

results=$(content_shell --dump-render-tree viewer_test.html)
echo $results

echo $results | grep -q PASS
passed=$?

echo $results | grep -q FAIL
failures=$?

echo $results | grep -q ERROR
errors=$?

if [[ ($failures != 0 && $errors != 0 && $passed == 0) ]]; then
    exit 0
fi

exit 1