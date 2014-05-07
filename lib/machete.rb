require 'machete/logger'
require 'machete/app'
require 'machete/buildpack_uploader'
require 'machete/buildpack_mode'
require 'machete/firewall'

module Machete
  def self.deploy_app(app_name, language, options={}, &block)
    app = Machete::App.new(app_name, language, options)
    app.push()
    block.call(app)
  end
end

