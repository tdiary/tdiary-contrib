#!/bin/bash
workspace=`pwd`
cd /usr/src/app
if [ ! -f tdiary.conf ]; then
	cp tdiary.conf.beginner tdiary.conf
fi
sed -i "s:^@data_path .*$:@data_path = \"${workspace}/data\":" tdiary.conf
bundle install --path=${workspace}/vendor/bundle --jobs=4 --retry=3 --with test:development
bundle exec rake assets:copy
export HTPASSWD=${workspace}/data/.htpasswd
if [ ! -f ${HTPASSWD} ]; then
	bundle exec bin/tdiary htpasswd
fi
