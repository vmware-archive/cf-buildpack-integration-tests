# Cloud Foundry Ruby Buildpack Integration Tests

## Machete

Machete is the CF buildpack test framework.

## Options

Online and offline mode (default: online):

    BUILDPACK_MODE=[online|offline]

Path to buildpacks folder:
    BUILDPACK_ROOT ../buildpacks

This root needs to contain the following buildpacks:

* cf-buildpack-go
* cf-buildpack-ruby

## Logging

Errors in the Machete library (usually shell errors) logged to _./machete.log_

## Notes

### RVM Version

You may encounter a silent early exit for scripts offline-build and online-build. This is an issue with RVM running
inside a bash script with `set -e`.

Ensure you have the latest stable version of RVM

    $ rvm --version # At least version 1.25.22

