require "spec_helper"
require "canary_breeder/canary_breeder"

module CanaryBreeder
  describe Breeder do
    let(:options) do
      double(:options,
             target: "some-target",
             username: "username",
             password: "password",
             number_of_zero_downtime_apps: 2,
             app_domain: "app-domain",
             number_of_instances_canary_instances: 3,
             canaries_path: "canaries-path"
      )
    end
    subject(:breeder) { described_class.new(options) }

    describe "#breed" do
      let(:runner) { double(:runner, :run! => nil) }
      let(:logger) { double(:logger).as_null_object }

      it "targets the provided api target" do
        expect(runner).to receive(:run!).with("gcf api some-target")
        breeder.breed(logger, runner)
      end

      it "logs in" do
        expect(runner).to receive(:run!).with("gcf login -u 'username' -p 'password'")
        breeder.breed(logger, runner)
      end

      it "selects pivotal organization and coal-mine space" do
        expect(runner).to receive(:run!).with("gcf target -o pivotal -s coal-mine")
        breeder.breed(logger, runner)
      end

      def self.it_pushes_an_app_if_it_does_not_exist(app_name)
        context "when app exists?" do
          before do
            runner.stub(:run!).with("gcf app #{app_name}")
          end

          it "does not push a an app" do
            expect(runner).to_not receive(:run!).with(/gcf push #{app_name}/)
            breeder.breed(logger, runner)
          end
        end

        context "when app does not exist" do
          before do
            runner.stub(:run!).with("gcf app #{app_name}") { raise CfDeployer::CommandRunner::CommandFailed }
          end

          it "pushes an app" do
            expect(runner).to receive(:run!).with(/gcf push #{app_name}/)
            breeder.breed(logger, runner)
          end
        end
      end

      describe "zero downtime canary" do
        it_pushes_an_app_if_it_does_not_exist("zero-downtime-canary1")
        it_pushes_an_app_if_it_does_not_exist("zero-downtime-canary2")
      end

      describe "aviary" do
        it_pushes_an_app_if_it_does_not_exist("aviary")
      end

      describe "cpu canary" do
        it_pushes_an_app_if_it_does_not_exist("cpu")
      end

      describe "disk canary" do
        it_pushes_an_app_if_it_does_not_exist("disk")
      end

      describe "memory canary" do
        it_pushes_an_app_if_it_does_not_exist("memory")
      end

      describe "network canary" do
        it_pushes_an_app_if_it_does_not_exist("network")
      end

      describe "instances canary" do
        it_pushes_an_app_if_it_does_not_exist("instances-canary")
      end
    end
  end
end