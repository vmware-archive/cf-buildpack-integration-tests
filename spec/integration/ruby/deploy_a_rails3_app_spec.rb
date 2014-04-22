require 'spec_helper'

describe 'deploying a rails 3 application' do
  it 'make the homepage available' do
    Machete.deploy_app("rails3_mri_193", :ruby, {
      cmd: "bundle exec rake db:migrate && bundle exec rails s -p $PORT",
      with_pg: true
    }) do |app|
      expect(app.homepage_html).to include('hello')
    end
  end
end
