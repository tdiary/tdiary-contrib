#!/bin/bash
cd /workspaces/core
bundle install --path=vendor/bundle --jobs=4 --retry=3
bundle exec rake assets:copy
