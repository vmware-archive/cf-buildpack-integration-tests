#!/bin/bash --login

source "$HOME/.rvm/scripts/rvm"
rvm use 1.9.3

bosh_lite_path=~/workspace/bosh-lite-2nd-instance
script_path=`pwd`

cd ~/workspace/cf-release
bundle
./update
rm -f dev_releases/*.yml
bundle exec bosh create release

cd $bosh_lite_path
vagrant destroy -f
vagrant up --provider vmware_fusion
bundle exec bosh target 192.168.100.4
bundle exec bosh login admin admin
./scripts/prepare-director.sh
./scripts/add-route
wget http://bosh-jenkins-gems-warden.s3.amazonaws.com/stemcells/latest-bosh-stemcell-warden.tgz -O latest-bosh-stemcell-warden.tgz
bundle exec bosh upload stemcell latest-bosh-stemcell-warden.tgz
./scripts/make_manifest_spiff

cd ~/workspace/cf-release
bundle exec bosh upload release dev_releases/cf-*.yml

cd $bosh_lite_path
bundle exec bosh deployment manifests/cf-manifest.yml
bundle exec bosh -n deploy

cd $script_path
VAGRANT_CWD=$bosh_lite_path ./enable_bosh_enterprise_firewall.rb

