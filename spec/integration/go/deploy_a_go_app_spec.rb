require "spec_helper"

describe 'deploying a go app' do
  it "makes the homepage available" do
    Machete.deploy_app("go_app", :go) do |app|
      expect(app.homepage_html).to include "go, world"
    end
  end
end
