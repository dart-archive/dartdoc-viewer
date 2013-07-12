# Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# This script is used to redirect HTTP requests to retrieve the correct
# files from Google Cloud Storage.

import logging
import urllib2
from webapp2 import *
from google.appengine.ext import blobstore
from google.appengine.ext.webapp import blobstore_handlers
from google.appengine.api import files

# Paths to Cloud Storage for dev server requests.
LOCAL_PATH = 'http://dartlang-docgen.storage.googleapis.com/'
LOCAL_VERSION = 'http://dartlang-docgen.storage.googleapis.com/VERSION'

# Paths to Cloud Storage for App Engine requests.
GS_PATH = '/gs/dartlang-docgen/'
GS_VERSION = '/gs/dartlang-docgen/VERSION'

ONE_HOUR = 60 * 60
ONE_DAY = ONE_HOUR * 24
ONE_WEEK = ONE_DAY * 7

class RequestHandler(blobstore_handlers.BlobstoreDownloadHandler):
  """ Used for handling HTTP requests on the dev server and on App Engine. """

  def get(self):
    """ Retrieves the file from Cloud Storage. """
    # Cloud Storage doesn't work on the dev server, so requests are 
    # handled differently depending on the origin.
    if os.environ['SERVER_SOFTWARE'].startswith('Development'):
      self.GetLocal()
    else:
      self.GetGoogleStorage()

  def GetLocal(self):
    """ Used for local, dev server HTTP requests. """
    version = urllib2.urlopen(LOCAL_VERSION).read()
    path = LOCAL_PATH + version + self.request.path[len('docs/'):]
    result = urllib2.urlopen(path).read()
    self.HandleCacheAge(path)
    self.response.out.write(result)

  def GetGoogleStorage(self):
    """ Used for App Engine HTTP requests. """
    version_key = blobstore.create_gs_key(GS_VERSION)
    blob_reader = blobstore.BlobReader(version_key)
    version = blob_reader.read()
    path = GS_PATH + version + self.request.path[len('docs/'):]
    gs_key = blobstore.create_gs_key(path)
    self.HandleCacheAge(path)
    self.send_blob(gs_key)

  def HandleCacheAge(self, path):
    """ Assigns a document a length of time it will live in the cache. """
    age = None
    if re.search(r'(png|jpg)$', path):
      age = ONE_DAY
    elif path.endswith('.ico'):
      age = ONE_WEEK
    else:
      age = ONE_HOUR
    self.response.headers['Cache-Control'] = 'max-age=' + \
        str(age) + ',s-maxage=' + str(age)
    
application = WSGIApplication(
  [
    ('/docs/.*', RequestHandler),
  ], debug=True)
