require 'spec_helper'

describe 'deploying a rack application' do
  it 'make the homepage available' do
    Machete.deploy_app("sinatra_web_app", :ruby, {with_db: false}) do |app|
      expect(app.homepage_html).to include('Hello world!')
    end
  end
end
