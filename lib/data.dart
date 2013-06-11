/**
 * Library to hold all the data needed in the app. 
 */
library data;

import 'package:web_ui/web_ui.dart';
import 'package:dartdoc_viewer/page.dart';

//Pages generated from the YAML file. Keys are the title of the pages. 
Map<String, Page> pageIndex = toObservable({});
