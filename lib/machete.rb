require 'machete/app'

module Machete
  def self.deploy_app(app_name, &block)
    app = Machete::App.new(app_name)
    app.push
    block.call(app)
  end
end

