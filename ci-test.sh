#!/bin/bash

RAILS_ENV=test;bundle install
RAILS_ENV=test;bundle exec rake db:create
RAILS_ENV=test;bundle exec rake db:migrate
rm -rf spec/reports
 RAILS_ENV=test;bundle exec rspec --format RspecJunitFormatter --out spec/reports/rspecs.xml

