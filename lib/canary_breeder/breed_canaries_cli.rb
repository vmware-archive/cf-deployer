require 'optparse'

module CanaryBreeder
  class Cli
    class OptionError < RuntimeError; end

    OPTIONS = {
      number_of_zero_downtime_apps: nil,
      number_of_instances_canary_instances: nil,
      number_of_instances_per_app: 1,
      app_domain: nil,
      canaries_path: nil,
      target: nil,
      username: nil,
      password: nil,
      dry_run: false,
    }

    class Options < Struct.new(*OPTIONS.keys)
    end

    attr_reader :options

    def initialize(args)
      @args = args
      @options = Options.new

      OPTIONS.each do |opt, default|
        @options.send(:"#{opt}=", default)
      end
    end

    def parse!
      parser.parse!(@args)
      @options
    end

    def validate!
      if @options.number_of_zero_downtime_apps.nil?
        die "--number-of-zero-downtime-apps is required"
      end

      if @options.number_of_instances_canary_instances.nil?
        die "--number-of-instances-canary-instances is required"
      end

      if @options.app_domain.nil?
        die "--app-domain is required"
      end

      if @options.canaries_path.nil?
        die "--canaries-path is required"
      end

      if @options.target.nil?
        die "--target is required"
      end

      if @options.username.nil?
        die "--username is required"
      end

      if @options.password.nil?
        die "--password is required"
      end
    end

    private

    def die(msg)
      raise OptionError.new(msg)
    end

    def parser
      @parser ||= OptionParser.new do |opts|
        opts.banner = "Example: breed_canaries -d my_domain"

        opts.on(
          "--number-of-zero-downtime-apps NUMBER_OF_ZERO_DOWNTIME_APPS",
          %Q{Number of Zero-Downtime canary applications to push.}
        ) do |number_of_zero_downtime_apps|
          @options.number_of_zero_downtime_apps = number_of_zero_downtime_apps.to_i
        end

        opts.on(
          "--number-of-instances-canary-instances NUMBER_OF_INSTANCES_CANARY_INSTANCES",
          %Q{Number of instances for the Instances canary application.}
        ) do |number_of_instances_canary_instances|
          @options.number_of_instances_canary_instances = number_of_instances_canary_instances.to_i
        end

        opts.on(
          "--number-of-instances-per-app NUMBER_OF_INSTANCES_PER_APP",
          %Q{Number of instances for each canary app (disk, memory, cpu, network, aviary).}
        ) do |number_of_instances_per_app|
          @options.number_of_instances_per_app = number_of_instances_per_app.to_i
        end

        opts.on(
          "-d APP_DOMAIN",
          "--app-domain APP_DOMAIN",
          %Q{Domain to use for canary applications.}
        ) do |app_domain|
          @options.app_domain = app_domain
        end

        opts.on(
          "-c CANARIES_PATH",
          "--canaries-path CANARIES_PATH",
          %Q{Path to directory containing the canary apps.}
        ) do |canaries_path|
          @options.canaries_path = canaries_path
        end

        opts.on(
          "--target TARGET",
          %Q{Target of angry birds.}
        ) do |target|
          @options.target = target
        end

        opts.on(
          "--username USERNAME",
          %Q{User to push as.},
        ) do |username|
          @options.username = username
        end

        opts.on(
          "--password PASSWORD",
          %Q{Password for the user.},
        ) do |password|
          @options.password = password
        end

        opts.on(
          "--dry-run", "Only print the commands that would run. DEFAULT: #{@options.dry_run}"
        ) do |dry_run|
          @options.dry_run = dry_run
        end
      end
    end
  end
end
