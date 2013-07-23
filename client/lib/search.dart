/**
 * A library for searching and filtering documentation.
 */
library search;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/read_yaml.dart';
import 'package:dartdoc_viewer/data.dart';

/** Search Index */
List<String> index = [];

class SearchResult implements Comparable {

  /** Qualified name of this search result references. */
  String element;

  /** Score of the search result match. Higher is better. */
  int score;

  int position;
  /**
   * Order results with higher scores before lower scores.
   */
  int compareTo(SearchResult other) => other.score.compareTo(score);

  SearchResult(this.element, this.score);
}

/**
 * Returns a list of up to [maxResults] number of [SearchResult]s based off the
 * searchQuery. 
 * 
 * A score is given to each potential search result based off how likely it is
 * the appropriate qualified name to return for the search query. 
 */
List<SearchResult> lookupSearchResults(String searchQuery, int maxResults) {

  var scoredResults = <SearchResult>[];
  var resultSet = new Set<String>();
  var queryList = searchQuery.trim().toLowerCase().split(' ');
  queryList.forEach((q) => resultSet.addAll(index.where((e) =>
    e.toLowerCase().contains(q))));
  
  for (var r in resultSet) {
    int score = 0;
    var lowerCaseResult = r.toLowerCase();
    
    var splitDotQueries = [];
    // If the search was for a named constructor (Map.fromIterable), give it a
    // score boost of 200. 
    queryList.forEach((q) {
      if (q.contains('.') && lowerCaseResult.endsWith(q)) {
        score += 200;
        splitDotQueries = q.split('.');
      }
    });
    queryList.addAll(splitDotQueries);
    
    var qualifiedNameParts = lowerCaseResult.split('.');
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
      // give score an extra point boost proportional to the number of segments.
      if (qualifiedNameParts.last == q) {
        score += 500 - (qualifiedNameParts.length * 100);
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
  updatePositions(scoredResults);
  if (scoredResults.length > maxResults) {
    return scoredResults.take(maxResults).toList();
  } else {
    return scoredResults;
  } 
}

void updatePositions(List<SearchResult> list) {
  for(int i = 0; i < list.length; i++) {
    list[i].position = i;
  }
}
