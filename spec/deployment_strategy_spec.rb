require "base64"
require "json"

require "spec_helper"
require "cf_deployer/deployment"
require "cf_deployer/release_manifest_generator"
require "cf_deployer/deployment_strategy"

module CfDeployer
  describe DeploymentStrategy do
    let(:deployment_path) { Dir.mktmpdir("deployment_path") }
    let(:generated_manifest) { Tempfile.new("generated-manifest.yml") }

    let(:runner) { FakeCommandRunner.new }

    let(:bosh) { FakeBosh.new }
    let(:deployment) { Deployment.new(deployment_path) }
    let(:release_repo) { FakeReleaseRepo.new "./repos/cf-release" }
    let(:manifest_generator) { ReleaseManifestGenerator.new runner, release_repo, "doesnt-matter", generated_manifest.path }
    let(:release_name) { "some-release-name" }

    subject { described_class.new(bosh, deployment, manifest_generator, release_name, release_repo) }

    describe "#install_hook" do
      let(:some_hook) do
        Class.new do
          attr_reader :triggered_pre_deploy, :triggered_post_deploy

          def pre_deploy
            @triggered_pre_deploy = true
          end

          def post_deploy
            @triggered_post_deploy = true
          end
        end.new
      end

      it "sets up a hook for deploying" do
        subject.stub(:do_deploy)

        subject.install_hook(some_hook)

        expect {
          subject.deploy!
        }.to change {
          [ some_hook.triggered_pre_deploy,
            some_hook.triggered_post_deploy,
          ]
        }.to([true, true])
      end
    end

    describe "#deploy!" do
      it "calls pre_deploy and post_deploy hooks before and after deploying" do
        sequence = []

        some_hook =
          Class.new do
            define_method(:pre_deploy) do
              sequence << :pre_deploy
            end

            define_method(:post_deploy) do
              sequence << :post_deploy
            end
          end

        subject.install_hook(some_hook.new)

        subject.stub(:do_deploy) { sequence << :deploying }

        expect {
          subject.deploy!
        }.to change {
          sequence
        }.from([]).to([:pre_deploy, :deploying, :post_deploy])
      end
    end
  end
end
