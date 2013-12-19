module CfDeployer
  module CommandRunner
    class SpawnAndWait
      def initialize(logger)
        @logger = logger
      end

      def run!(command, options = {})
        @logger.log_execution(command)
        spawner = SpawnOnly.new(command, options)
        spawner.spawn

        yield if block_given?

        spawner.wait
      end
    end
  end
end
