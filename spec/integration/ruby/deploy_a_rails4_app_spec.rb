require 'spec_helper'

describe 'deploying a rails 4 application' do
  it 'make the homepage available' do
    Machete.deploy_app("rails4_web_app", :ruby, {
      with_pg: true
    }) do |app|
      expect(app.homepage_html).to include('The Kessel Run')
    end
  end
end
