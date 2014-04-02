require 'machete/app'

module Machete
  def self.deploy_app(app_name, cmd, &block)
    app = Machete::App.new(app_name, cmd)
    app.push
    block.call(app)
  end
end

