#!/bin/bash --login

source "$HOME/.rvm/scripts/rvm"
rvm use 1.9.3

cd ~/workspace/cf-release
bundle
rm -f dev_releases/*.yml
bundle exec bosh create release

cd ~/workspace/bosh-lite
vagrant destroy -f
vagrant up --provider vmware_fusion
bundle exec bosh target 192.168.50.4
bundle exec bosh login admin admin
scripts/add-route
vagrant ssh -c "sudo sv restart director"
bundle exec bosh upload stemcell latest-bosh-stemcell-warden.tgz

cd ~/workspace/cf-release
./update

cd ~/workspace/bosh-lite
./scripts/make_manifest_spiff

cd ~/workspace/cf-release
bundle exec bosh upload release dev_releases/cf-*.yml

cd ~/workspace/bosh-lite
bundle exec bosh deployment manifests/cf-manifest.yml
bundle exec bosh -n deploy
