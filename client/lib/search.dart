// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/**
 * A library for searching and filtering documentation.
 *
 * Given a search query, a set of ranked results is created to determine the
 * best member to match that query. Priority is given in the following order:
 * library, class, typedef, and class member or top-level library member.
 * Results with matches in the last section of their qualified names are
 * given a higher rank than those with matches in inner members of the
 * qualified name.
 */
library search;

import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:dartdoc_viewer/location.dart';

/** Search Index */
@reflectable Map<String, String> index = {};

@reflectable class SearchResult implements Comparable {

  /** Qualified name of this search result references. */
  String element;

  static const typesThatLinkWithinAParentPage = const ['method', 'operator',
    'getter', 'setter', 'variable', 'constructor', 'property' ];

  String get url {
    if (!typesThatLinkWithinAParentPage.contains(type)) return element;
    var location = new DocsLocation(element);
    var sub = location.subMemberName == null
        ? location.memberName
        : location.subMemberName;
    if (sub == null) return element;
    var newLocation = new DocsLocation(location.parentQualifiedName);
    newLocation.anchor = newLocation.toHash(sub);
    return newLocation.withAnchor;
  }

  /** This element's member type. */
  String type;

  /** Score of the search result match. Higher is better. */
  int score;

  /** Its numerical position from the top of the list of results. */
  int position;

  /**
   * Order results with higher scores before lower scores.
   */
  int compareTo(SearchResult other) => other.score.compareTo(score);

  SearchResult(this.element, this.type, this.score);

  toString() => "SearchResult($element, $type, $score)";
}

/// The value of each type of member.
@reflectable Map<String, int> value = {
  'library' : 1,
  'class' : 2,
  'typedef' : 3,
  'method' : 4,
  'getter' : 4,
  'setter' : 4,
  'operator' : 4,
  'property' : 4,
  'constructor' : 4
};

/**
 * Returns a list of up to [maxResults] number of [SearchResult]s based off the
 * searchQuery.
 *
 * A score is given to each potential search result based off how likely it is
 * the appropriate qualified name to return for the search query.
 */
@reflectable
List<SearchResult> lookupSearchResults(String query, int maxResults) {
  if (query == '') return [];

  var stopwatch = new Stopwatch()..start();

  var scoredResults = <SearchResult>[];
  var resultSet = new Set<String>();
  var queryList = query.trim().toLowerCase().split(' ');
  for (var key in index.keys) {
    var lower = key.toLowerCase();
    if (queryList.any((q) => lower.contains(q))) {
        resultSet.add(key);
    }
  }

  for (var r in resultSet) {
    /// If it is taking too long to compute the search results, time out and
    /// return an empty list of results.
   if (stopwatch.elapsedMilliseconds > 500) {
      return [];
    }
    int score = 0;
    var lowerCaseResult = r.toLowerCase();
    var type = index[r];

    var splitDotQueries = [];
    // If the search was for a named constructor (Map.fromIterable), give it a
    // score boost of 200.
    queryList.forEach((q) {
      if (q.contains('.') && lowerCaseResult.endsWith(q)) {
        score += 100;
        splitDotQueries = q.split('.');
      }
    });
    queryList.addAll(splitDotQueries);

    if (lowerCaseResult.contains('.dom.')) {
      lowerCaseResult = lowerCaseResult.replaceFirst('.dom', '');
    }
    var qualifiedNameParts = lowerCaseResult.split('.');
    qualifiedNameParts.forEach((q) => q.trim());

    queryList.forEach((q) {
      // If it is a direct match to the last segment of the qualified name,
      // give score an extra point boost depending on the member type.
      if (qualifiedNameParts.last == q) {
        score += 1000 ~/ value[type];
      } else if (qualifiedNameParts.last.startsWith(q)) {
        score += 750 ~/ value[type];
      } else if (qualifiedNameParts.last.contains(q)) {
        score += 500 ~/ value[type];
      }

      for (int i = 0; i < qualifiedNameParts.length - 1; i++) {
        // If it is a direct match to any segment of the qualified name, give
        // score boost depending on the member type.
        // If it starts with the search query, give it aboost depending on
        // the member type and the percentage of the segment the query fills.
        // If it contains the search query, give it an even smaller score boost
        // also depending on the member type and the percentage of the segment
        // the query fills.
        if (qualifiedNameParts[i] == q) {
          score += 300 ~/ value[type];
        } else if (qualifiedNameParts[i].startsWith(q)) {
          var percent = q.length / qualifiedNameParts[i].length;
          score += (300 * percent) ~/ value[type];
        } else if (qualifiedNameParts[i].contains(q)) {
          var percent = q.length / qualifiedNameParts[i].length;
          score += (150 * percent) ~/ value[type];
        }
      }

      // If the result item is part of the dart library, give it a small boost.
      if (qualifiedNameParts.first == 'dart') {
        score += 50;
      }
    });
    scoredResults.add(new SearchResult(r, type, score));
  }

  /// If it is taking too long to compute the search results, time out and
  /// return an empty list of results.
  if (stopwatch.elapsedMilliseconds > 500) {
    return [];
  }
  scoredResults.sort();
  updatePositions(scoredResults);
  if (scoredResults.length > maxResults) {
    return scoredResults.take(maxResults).toList();
  } else {
    return scoredResults;
  }
}

@reflectable void updatePositions(List<SearchResult> list) {
  for(int i = 0; i < list.length; i++) {
    list[i].position = i;
  }
}