require 'spec_helper'

describe 'deploying a rack application' do
  describe 'online mode' do
    it 'should respond with hello world' do
      deploy_app("sinatra_web_app") do |app|
        expect(app.homepage_html).to include('Hello world!')
      end
    end
  end
end

def deploy_app(app_name, &block)
  app = Machete::App.new(app_name)
  app.push
  block.call(app)
end

