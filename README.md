# Cloud Foundry Ruby Buildpack Integration Tests

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
