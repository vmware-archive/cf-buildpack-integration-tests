require "spec_helper"

describe 'deploying a jruby 1.7.3 application' do
  xit "deploys a jruby 1.7.3 (legacy jdk) properly" do
    Machete.deploy_app("ruby_193_jruby_173", :ruby) do |app|
      expect(app.output).to match("Installing JVM: openjdk1.7.0_25")
      expect(app.output).to match("ruby-1.9.3-jruby-1.7.3")
      expect(app.output).not_to include("OpenJDK 64-Bit Server VM warning")
      puts app.output
    end
  end
end
