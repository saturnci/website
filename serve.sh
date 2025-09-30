#!/bin/bash

ruby build.rb
cd public
ruby -run -e httpd . -p 8000