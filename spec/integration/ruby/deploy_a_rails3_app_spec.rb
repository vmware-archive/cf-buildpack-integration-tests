require 'spec_helper'

describe 'deploying a rails 3 application' do
  it 'make the homepage available' do
    Machete.deploy_app("rails3_mri_193", :ruby, {
      with_pg: true
    }) do |app|
      expect(app.homepage_html).to include('hello')
    end
  end
end
