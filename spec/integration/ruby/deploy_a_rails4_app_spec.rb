require 'spec_helper'

describe 'deploying a rails 4 application' do
  it 'make the homepage available' do
    Machete.deploy_app("rails4_web_app", :ruby, {
      cmd: "bundle exec rake db:migrate && bundle exec rails s -p $PORT",
      with_db: true
    }) do |app|
      expect(app.homepage_html).to include('The Kessel Run')
    end
  end
end
