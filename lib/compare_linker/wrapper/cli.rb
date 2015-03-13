require 'thor'

module CompareLinker
  module Wrapper
    class CLI < Thor
      def self.exit_on_failure?
        true
      end

      desc 'version', 'Show the CompareLinker::Wrapper version'
      map %w(-v --version) => :version

      def version
        puts "CompareLinker::Wrapper version #{::CompareLinker::Wrapper::VERSION}"
      end

      desc 'compare', 'compare gemfile.lock'
      option :debug, type: :boolean, default: false
      option :verbose, type: :boolean, default: false

      def compare(*args)
        setup_logger(options)
        gemfile_locks = [
          'Gemfile.lock'
        ]
        params = {
          base: args[0],
          head: 'HEAD'
        }
      rescue StandardError => e
        suggest_messages(options)
        raise e
      end
      default_command :compare

      no_commands do
        def logger
          ::CompareLinker::Wrapper.logger
        end

        def setup_logger(options)
          if options[:debug]
            logger.level = Logger::DEBUG
          elsif options[:verbose]
            logger.level = Logger::INFO
          end
          logger.debug(options)
        end

        def suggest_messages(options)
          logger.error 'Have a question? Please ask us:'
          logger.error ISSUE_URL
          logger.error 'options:'
          logger.error options
        end

        # http://stackoverflow.com/a/23955971/104080
        def method_missing(method, *args)
          self.class.start([self.class.default_command, method.to_s] + args)
        end
      end
    end
  end
end
