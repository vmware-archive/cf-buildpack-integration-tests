require "spec_helper"

describe 'deploying a firewall test app', :null_buildpack do
  it "makes the homepage available" do
    Machete.deploy_app("firewall", :null) do |app|
      expect(app.homepage_html).to include "Index of"
    end
  end
end
