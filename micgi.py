#!/bin/env python
# -*- encoding: utf-8 -*-
import urlparse
from string import Template
import os

print "Content-Type: text/html"
print

print """
<html>
<head>
	<title>Python!</title>
</head>
<body>
"""

body = Template("""
<h1>ls! En Python!</h1>
<img src='${image}'/>
<small><a href="/">Vuelve</a></small>
""")

print body.substitute(dict(image="http://www.python.org/images/python-logo.gif"))

print "<p><ul>"

par = urlparse.parse_qs(os.environ['QUERY_STRING'])
if not "dir" in par.keys():
	par["dir"] = ["."]
for file in os.listdir(par["dir"][0]):
	print "<li><a href='%s'>%s</a></li>" % (file,file)

print "</ul></p>"

print "<code>%s parameters = %s</code>" % (os.environ['REQUEST_METHOD'], par)
print """
</body>
</html>
"""
