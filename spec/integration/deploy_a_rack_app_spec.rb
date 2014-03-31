require 'spec_helper'

describe 'deploying a rack application' do
  it 'should respond with hello world' do
    Machete.deploy_app("sinatra_web_app") do |app|
      expect(app.homepage_html).to include('Hello world!')
    end
  end
end
