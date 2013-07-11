/**
 * Library to hold all the data needed in the app. 
 */
library data;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/item.dart';

//Pages generated from the YAML file. Keys are the title of the pages. 
Map<String, Item> pageIndex = toObservable({});

// Since library names can contain '.' characters, they must be mapped to
// a new form for linking purposes. This maps original library names to names
// with '%' characters replacing the '.' characters for consistency.
Map<String, String> libraryNames = {};