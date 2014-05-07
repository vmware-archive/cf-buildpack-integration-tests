#!/bin/bash

set -e

BUNDLE_GEMFILE=cf.Gemfile bundle
BUNDLE_GEMFILE=cf.Gemfile BUILDPACK_MODE=offline rspec cf_spec
