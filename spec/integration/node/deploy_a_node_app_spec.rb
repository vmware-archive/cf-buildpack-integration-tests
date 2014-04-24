require "spec_helper"

describe 'deploying a nodejs app', :node_buildpack do
  it "makes the homepage available" do
    Machete.deploy_app("hello_world", :nodejs, {
      cmd: "node hello_world.js"
    }) do |app|
      expect(app.homepage_html).to include "Hello, World!"
    end
  end
end
