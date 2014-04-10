#!/usr/bin/env ruby

`mkdir -p tmp/buildpacks`

`git clone https://github.com/pivotal-cf-experimental/cf-buildpack-ruby tmp/buildpacks/cf-buildpack-ruby`
`git clone https://github.com/pivotal-cf-experimental/cf-buildpack-go tmp/buildpacks/cf-buildpack-go`

Dir.chdir("tmp/buildpacks/cf-buildpack-ruby")

`git remote add heroku-github https://github.com/heroku/heroku-buildpack-ruby`
`git fetch heroku-github`
puts `git merge heroku-github/master`

