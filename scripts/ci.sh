#!/bin/bash -l

uname_lower=$(echo `uname` | awk '{print tolower($0)}')
curl http://go-cli.s3.amazonaws.com/master/cf-$uname_lower-amd64.tgz | tar xzv
mkdir -p ./bin
mv cf bin/
export PATH=/Users/pivotal/.rvm/bin:/var/vcap/packages/ruby/bin:$PWD/bin:$PATH
rvm use ruby-2.0.0-p451
bundle install
rm -rf tmp_buildpacks
mkdir tmp_buildpacks
git clone https://github.com/cloudfoundry/cf-buildpack-ruby tmp_buildpacks/cf-buildpack-ruby
git clone https://github.com/pivotal-cf-experimental/cf-buildpack-go tmp_buildpacks/cf-buildpack-go
git clone https://github.com/pivotal-cf-experimental/cf-buildpack-nodejs tmp_buildpacks/cf-buildpack-nodejs
cf create-org pivotal
cf target -o pivotal
cf create-space integration-tests
cf target -o pivotal -s integration-tests
export BUILDPACK_ROOT=tmp_buildpacks
bundle exec rspec -f d && BUILDPACK_MODE=offline bundle exec rspec
