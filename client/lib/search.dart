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
import 'dart:math';

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
@reflectable const Map<String, int> value = const {
  'library' : 2,
  'class' : 2,
  'typedef' : 3,
  'method' : 4,
  'getter' : 4,
  'setter' : 4,
  'operator' : 4,
  'property' : 4,
  'constructor' : 4
};

bool _nullFilter(_) => true;


/// Represents a hit when searching, and stores basic information about the
/// matched item.
class Hit {
  /// The qualified name of the matched object, e.g. dart-core.Object.hashCode
  final String name;

  ///
  final String lower;
  // Really an enum of the keys in [value]
  final String type;

  factory Hit(String name, String lower) {
    var withoutDom =
        lower.contains('.dom.') ? lower.replaceFirst('.dom', '') : lower;
    var type = index[name];
    return new Hit.withFinals(name, withoutDom, type);
  }

  Hit.withFinals(this.name, this.lower, this.type);

  get weight => value[type];

  toString() => "Hit($name)";

  /// Calculate a score boost proportional to [increase], the [weight] given
  /// to our [type] of object.
  score(num increase) => increase ~/ weight;
}

/// The maximum number of search results we will examine. Saves time on
/// searches with very large numbers of matches (e.g. single letters)
const int MAX_RESULTS_TO_CONSIDER = 1000;

List<String> splitQueryTerms(String query) {
  var queryList = query.trim().toLowerCase().split(' ');
  queryList = queryList.map((x) => x.replaceAll(":", '-')).toList();
  // If someone types a dot we don't know if they meant e.g. polymer.builder
  // library or polymer.CustomTag, or polymer.builder.CommandLineOptions.
  // So add a query term with those replaced with hyphens, but also split
  // it up into individual words in case that's wrong. And ignore split
  // words with two or fewer characters, which introduce too many matches.
  var splitDots = queryList.map((x) => x.split(".")).toList();
  for (List split in splitDots) {
    if (split.length > 1) {
      queryList.addAll(split.where((x) => x.length > 2));
      queryList.add(split.join("-"));
    }
  }
  return queryList;
}

/**
 * Returns a list of up to [maxResults] number of [SearchResult]s based off the
 * searchQuery.
 *
 * A score is given to each potential search result based off how likely it is
 * the appropriate qualified name to return for the search query.
 */
@reflectable
List<SearchResult> lookupSearchResults(String query, int maxResults,
    [Function filter = _nullFilter]) {
  if (query == '') return [];

  var stopwatch = new Stopwatch()..start();

  var scoredResults = <SearchResult>[];
  var resultSet = new List<Hit>();
  var queryList = splitQueryTerms(query);

  for (var key in index.keys) {
    var lower = key.toLowerCase();
    if (queryList.any((q) => lower.contains(q))) {
        resultSet.add(new Hit(key, lower));
    }
  }

  for (Hit r in resultSet.take(MAX_RESULTS_TO_CONSIDER)) {
    /// If it is taking too long to compute the search results, time out and
    /// return an empty list of results.
   if (stopwatch.elapsedMilliseconds > 500) {
      return [];
    }
    int score = 0;

    var splitDotQueries = [];
    // If the search was for a named constructor (Map.fromIterable), give it a
    // score boost of 200.
    queryList.forEach((q) {
      if (q.contains('.') && r.lower.endsWith(q)) {
        score += 100;
        splitDotQueries = q.split('.');
      }
    });
    queryList.addAll(splitDotQueries);

    var location = new DocsLocation(r.lower);
    var qualifiedNameParts = location.componentNames.skip(1).toList();

    // We allow results that aren't within the current context, but we
    // demote them severely.
    if (!filter(location)) {
      score -= 500;
    }

    // If something is named exactly what you typed, including case, then
    // it should be first.
    if (r.name == query) {
      score += 1000;
    }
    // If it's a partial case-sensitive match, give it a bonus.
    if ((r.name != r.lower) && r.name.contains(query)) {
      score += 150;
    }

    queryList.forEach((q) {
      // If it is a direct match to the last segment of the qualified name,
      // give score an extra point boost depending on the member type.
      if (qualifiedNameParts.last == q) {
        score += r.score(1000);
      } else if (qualifiedNameParts.last.startsWith(q)) {
        score += r.score(750);
      } else if (qualifiedNameParts.last.contains(q)) {
        score += r.score(500);
      }

      for (var segment in qualifiedNameParts) {
        // If it is a direct match to any segment of the qualified name, give
        // score boost depending on the member type.
        // If it starts with the search query, give it aboost depending on
        // the member type and the percentage of the segment the query fills.
        // If it contains the search query, give it an even smaller score boost
        // also depending on the member type and the percentage of the segment
        // the query fills.
        if (segment == q) {
          score += r.score(300);
        } else if (segment.startsWith(q)) {
          var percent = q.length / segment.length;
          score += r.score(300 * percent);
        } else if (segment.contains(q)) {
          var percent = q.length / segment.length;
          score += r.score(150 * percent);
        }
      }

      // If the result item is part of the dart library, give it a small boost.
      if (location.libraryName.startsWith('dart')) {
        score += 50;
      }
    });
    scoredResults.add(new SearchResult(r.name, r.type, score));
  }

  /// If it is taking too long to compute the search results, time out and
  /// return an empty list of results.
  if (stopwatch.elapsedMilliseconds > 500) {
    return [];
  }
  scoredResults.sort();
  updatePositions(scoredResults.take(maxResults).toList());
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
