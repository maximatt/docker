#!/usr/bin/python
# -*- coding: utf-8 -*-

import os 
os.environ['PYTHON_EGG_CACHE'] = '/home/trac/.python-eggs'

import trac.web.main
def application(environ, start_response):
  environ.setdefault('trac.env_parent_dir','/home/trac/repository')
  return trac.web.main.dispatch_request(environ,start_response)

