#!/bin/bash -l

set -e

# Build online package
./bin/package online

# Create buildpack on CF
cf api api.10.244.0.34.xip.io --skip-ssl-validation
cf login -u admin -p admin -o pivotal -s integration
cf delete-buildpack ${language}-test-buildpack -f
cf create-buildpack ${language}-test-buildpack ${language}_buildpack.zip 1 --enable

# RVM
export PATH=/Users/pivotal/.rvm/bin:$PATH
rvm use default

# Run specs
BUNDLE_GEMFILE=cf.Gemfile bundle
BUNDLE_GEMFILE=cf.Gemfile rspec cf_spec

# Release buildpack
mv ${language}_buildpack.zip /tmp/${language}_buildpack_${BUILD_NUMBER}_online.zip