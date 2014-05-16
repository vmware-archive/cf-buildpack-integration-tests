#!/bin/bash -l

set -e

# Build offline package
./bin/package offline

# Creat buildpack on CF
cf api api.10.245.0.34.xip.io
cf login -u admin -p admin -o pivotal -s integration
cf create-buildpack $language-test-buildpack $language_buildpack.zip 1 --enable

# Run specs

echo
echo "******* CI ***************************************************"
echo "******* Adding RVM and using Ruby 2.0"
export PATH=/Users/pivotal/.rvm/bin:$PATH
rvm use ruby-2.0.0-p451

BUNDLE_GEMFILE=cf.Gemfile bundle
BUNDLE_GEMFILE=cf.Gemfile BUILDPACK_MODE=offline rspec cf_spec

# Release buildpack
mkdir -p release
mv $language_buildpack.zip release/$language_buildpack_$BUILD_NUMBER_offline.zip