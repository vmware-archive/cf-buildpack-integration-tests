require 'machete/logger'
require 'machete/app'

module Machete
  def self.deploy_app(app_name, language, options={}, &block)
    app = Machete::App.new(app_name, language, options[:cmd])
    app.push(options[:with_db])
    block.call(app)
  end
end

