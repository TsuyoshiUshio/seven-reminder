#!/bin/bash

RAILS_ENV=test;bundle install
RAILS_ENV=test;bundle exec rake db:create
RAILS_ENV=test;bundle exec rake db:migrate
RAILS_ENV=test;bundle exec rspec -f JUnit -o spec/reports/results.xml