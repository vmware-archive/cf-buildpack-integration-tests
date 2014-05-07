#!/bin/bash

set -e

BUNDLE_GEMFILE=cf.Gemfile bundle
BUNDLE_GEMFILE=cf.Gemfile rspec cf_spec
