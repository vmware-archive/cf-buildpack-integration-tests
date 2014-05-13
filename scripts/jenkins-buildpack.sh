#!/bin/bash -l

echo
echo "******* CI ***************************************************"
echo "******* Set vagrant root on CI machine - needed by firewall scripts"
export VAGRANT_CWD=/Users/pivotal/workspace/bosh-lite

echo
echo "******* CI ***************************************************"
echo "******* Fetching CF CLI"
uname_lower=$(echo `uname` | awk '{print tolower($0)}')
curl http://go-cli.s3.amazonaws.com/master/cf-$uname_lower-amd64.tgz | tar xzv

echo
echo "******* CI ***************************************************"
echo "******* Installing CF CLI on path"
mkdir -p ./bin
mv cf bin/
export PATH=$PWD/bin:$PATH

echo
echo "******* CI ***************************************************"
echo "******* Adding VCAP ruby to path"
export PATH=/var/vcap/packages/ruby/bin:$PATH

echo
echo "******* CI ***************************************************"
echo "******* Adding RVM and using Ruby 2.0"
export PATH=/Users/pivotal/.rvm/bin:$PATH
rvm use ruby-2.0.0-p451

echo
echo "******* CI ***************************************************"
echo "******* Bundling"
export BUNDLE_GEMFILE=cf.Gemfile
bundle install

echo
echo "******* CI ***************************************************"
echo "******* Create CF org and space"
cf login -u admin -p admin
cf create-org pivotal
cf target -o pivotal
cf create-space integration
cf target -o pivotal -s integration


# ----- run

echo
echo "******* CI ***************************************************"
echo "******* Running offline specs"
BUILDPACK_MODE=offline rspec -f d cf_spec

if [ $? -ne 0 ]; then
  exit 1
fi

echo
echo "******* CI ***************************************************"
echo "******* Running online specs"
bundle exec rspec -f d cf_spec

if [ $? -ne 0 ]; then
  exit 1
fi
