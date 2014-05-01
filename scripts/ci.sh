#!/bin/bash -l

echo "\n******* CI ***************************************************"
echo "******* Fetching CF CLI"
uname_lower=$(echo `uname` | awk '{print tolower($0)}')
curl http://go-cli.s3.amazonaws.com/master/cf-$uname_lower-amd64.tgz | tar xzv

echo "\n******* CI ***************************************************"
echo "******* Installing CF CLI on path"
mkdir -p ./bin
mv cf bin/
export PATH=$PWD/bin:$PATH

echo "\n******* CI ***************************************************"
echo "******* Adding VCAP ruby to path"
export PATH=/var/vcap/packages/ruby/bin:$PATH

echo "\n******* CI ***************************************************"
echo "******* Adding RVM and using Ruby 2.0"
export PATH=/Users/pivotal/.rvm/bin:$PATH
rvm use ruby-2.0.0-p451

echo "\n******* CI ***************************************************"
echo "******* Bundling"
bundle install

echo "\n******* CI ***************************************************"
echo "******* Fetching buildpacks for testing"
rm -rf tmp_buildpacks
mkdir tmp_buildpacks
git clone https://github.com/cloudfoundry/cf-buildpack-ruby tmp_buildpacks/cf-buildpack-ruby
git clone https://github.com/pivotal-cf-experimental/cf-buildpack-go tmp_buildpacks/cf-buildpack-go
git clone https://github.com/pivotal-cf-experimental/cf-buildpack-nodejs tmp_buildpacks/cf-buildpack-nodejs
export BUILDPACK_ROOT=tmp_buildpacks

echo "\n******* CI ***************************************************"
echo "******* Create CF org and space"
cf login -u admin -p admin
cf create-org pivotal
cf target -o pivotal
cf create-space integration-tests
cf target -o pivotal -s integration-tests

echo "\n******* CI ***************************************************"
echo "******* Running online specs"
rspec -f d

echo "\n******* CI ***************************************************"
echo "******* Running offline specs"
BUILDPACK_MODE=offline rspec -f d
