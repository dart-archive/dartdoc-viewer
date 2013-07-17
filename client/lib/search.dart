/**
 * A library for searching and filtering documentation.
 */
library search;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/read_yaml.dart';
import 'package:dartdoc_viewer/data.dart';

/// Search Index
List<String> index = [];

class SearchResult implements Comparable {

  /** Qualified name of this search result references. */
  String element;

  /** Score of the search result match. Higher is better. */
  int score;

  /**
   * Order results with higher scores before lower scores.
   * */
  int compareTo(SearchResult other) => other.score.compareTo(score);

  SearchResult(this.element, this.score);
}

List<SearchResult> lookupSearchResults(String searchQuery, int maxResults) {

  var scoredResults = <SearchResult>[];

  if (searchQuery.length <= 0) {
    return scoredResults;
  }
  
  var resultsSet = new Set<String>();

  var queryList = searchQuery.trim().toLowerCase().split(' ');

  queryList.forEach((q) => q.trim());
  
  queryList.forEach((q) => resultsSet.addAll(index.where((e) =>
    e.toLowerCase().contains(q))));

  for (var r in resultsSet) {
    int score = 0;
    var qualifiedNameParts = r.toLowerCase().split('.');
    qualifiedNameParts.forEach((q) => q.trim());
    // If the result item is part of the dart library, give it a 50 point boost.
    // Removes 'dart' from list of segments to avoid penalizing it later on. 
    if (qualifiedNameParts.first == 'dart') {
      score += 50;
      qualifiedNameParts.removeAt(0);
    }

    // If the result item is part of Object superclass, give a 50 point boost. 
    if (qualifiedNameParts.contains('object')) {
      score += 50;
    }

    queryList.forEach((q) {
      // If it is a direct match to the last segment of the qualified name, 
      // give score an extra 200 point boost. 
      if (qualifiedNameParts.last == q) {
        score += 200;
      }

      for (int i = 0; i < qualifiedNameParts.length; i++) {
        // If it is a direct match to any segment of the qualified name, give 
        // score proportional to how far away it is from the library level. 
        // If it starts with the search query, give it a score boost inversely 
        // proportional to how far away it is from the library level. 
        // if it contains the search query, give it an even smaller score boost, 
        // also inversely proportional to how far away it is from the library 
        // level. 
        if (qualifiedNameParts[i] == q) {
          score += 1000 - (i*100);
        } else if (qualifiedNameParts[i].startsWith(q)) {
          score += 200 - ((qualifiedNameParts.length - i)*10);
        } else if (qualifiedNameParts[i].contains(q)) {
          score += 100 - ((qualifiedNameParts.length - i)*10);
        }
      }
    });

    scoredResults.add(new SearchResult(r, score));
  }
  scoredResults.sort();
  
  if (scoredResults.length > maxResults) {
    return scoredResults.take(maxResults).toList();
  } else {
    return scoredResults;
  } 
}
