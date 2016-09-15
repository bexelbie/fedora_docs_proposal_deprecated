#!/bin/bash

rm -rf _images index.html latest _preview proposal public sitemap.xml _stylesheets
mv _package/main/* .
rm -rf _package
