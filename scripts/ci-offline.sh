#!/bin/bash

set -e

# Build offline package
./bin/package offline

# Creat buildpack on CF
cf create-buildpack $language-test-buildpack $language_buildpack.zip 1 --enable

BUNDLE_GEMFILE=cf.Gemfile bundle
BUNDLE_GEMFILE=cf.Gemfile BUILDPACK_MODE=offline rspec cf_spec

mkdir -p release

mv $language_buildpack.zip release/$language_buildpack_$BUILD_NUMBER_offline.zip