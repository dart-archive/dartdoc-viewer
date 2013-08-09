/**
 * A library for searching and filtering documentation.
 */
library search;

/** Search Index */
Map<String, String> index = {};

class SearchResult implements Comparable {

  /** Qualified name of this search result references. */
  String element;
  
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
}

Map<String, int> value = {
  'library' : 1,
  'class' : 2,
  'typedef' : 3,
  'method' : 4,
  'variable' : 4,
  'constructor' : 4
};

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
  queryList.forEach((q) => resultSet.addAll(index.keys.where((e) =>
    e.toLowerCase().contains(q))));
  
  for (var r in resultSet) {
    int score = 0;
    var lowerCaseResult = r.toLowerCase();
    var type = index[r];
    
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
    
    if (lowerCaseResult.contains('.dom.')) {
      lowerCaseResult = lowerCaseResult.replaceFirst('.dom.', '.');
    }
    var qualifiedNameParts = lowerCaseResult.split('.');
    qualifiedNameParts.forEach((q) => q.trim());
    
    queryList.forEach((q) {
      // If it is a direct match to the last segment of the qualified name, 
      // give score an extra point boost proportional to the number of segments.
      if (qualifiedNameParts.last == q) {
        score += 1000 ~/ value[type];
      } else if (qualifiedNameParts.last.startsWith(q)) {
        score += 750 ~/ value[type];
      } else if (qualifiedNameParts.last.contains(q)) {
        score += 500 ~/ value[type];
      }

      for (int i = 0; i < qualifiedNameParts.length - 1; i++) {
        // If it is a direct match to any segment of the qualified name, give 
        // score proportional to how far away it is from the library level
        // divied by the overall length of the qualified name. 
        // If it starts with the search query, give it a score boost inversely 
        // proportional to how far away it is from the library level. 
        // if it contains the search query, give it an even smaller score boost,
        // also inversely proportional to how far away it is from the library 
        // level. 
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
      
      // If the result item is part of the dart library, give it a 50 point boost. 
      if (qualifiedNameParts.first == 'dart') {
        score += 50;
      }
    });

    scoredResults.add(new SearchResult(r, type, score));
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
