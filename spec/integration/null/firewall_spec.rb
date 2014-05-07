require "spec_helper"

describe 'deploying a firewall test app', :null_buildpack do
  context "an app that does not access the internet" do
    let(:app_name) { "offline_app" }

    it "deploys the app successfully" do
      Machete.deploy_app(app_name, :null) do |app|
        expect(app.homepage_html).to include "Index of"
      end
    end
  end

  context "an app that accesses the internet" do
    let(:app_name) { "online_app" }

    if Machete::BuildpackMode.offline?

      it "causes an error when trying to access the internet" do
        pending("Waiting on a firewall rule that will reject the packet, not drop it")
        Machete.deploy_app(app_name, :null) do |app|
          expect(app.output).to include ""
        end
      end
    else
      it "is in online mode and does not fail" do
        Machete.deploy_app(app_name, :null) do |app|
          expect(app.homepage_html).to include "Index of"
        end
      end
    end
  end

  context "an app which uses AppDirect and its services" do
    let(:app_name) { "app_direct_app" }

    let(:manifest) { {
      'applications' => [
        {
          'name' => 'app-direct-app',
          'env' => {
            'APPDIRECT_URL' => ENV["APPDIRECT_URL"]
          }
        }
      ]
    } }

    it "successfully connects to AppDirect" do
      Machete.deploy_app(app_name, :null, manifest: manifest) do |app|
        expect(app.staging_log).to include "Connected to AppDirect"
      end
    end

    it "successfully connects to Postgres" do
      Machete.deploy_app(app_name, :null, manifest: manifest, with_pg: true) do |app|
        expect(app.homepage_html).to include "Connected to Postgres"
      end
    end
  end
end
