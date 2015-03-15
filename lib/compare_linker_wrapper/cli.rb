require 'thor'

module CompareLinkerWrapper
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc 'version', 'Show the CompareLinkerWrapper version'
    map %w(-v --version) => :version

    def version
      puts "CompareLinkerWrapper version #{::CompareLinkerWrapper::VERSION}"
    end

    desc 'compare', 'compare gemfile.lock'
    option :debug, type: :boolean, default: false
    option :verbose, type: :boolean, default: false
    option :base, type: :string, default: 'origin/master'
    option :head, type: :string, default: 'HEAD'
    option :file, type: :array
    option :formatter, type: :string, default: 'CompareLinker::Formatter::Text'

    def compare(*args)
      setup_logger(options)
      params = {
        head: options[:head],
        formatter: options[:formatter]
      }
      if options[:file] && options[:base]
        params[:base] = options[:base]
        params[:file] = options[:file]
      elsif options[:file]
        params[:base] = args[0]
        params[:file] = options[:file]
      elsif options[:base]
        params[:base] = options[:base]
        params[:file] = args
      else
        params[:base] = args.shift
        params[:file] = args
      end
      puts Linker.new('.').link(params)
    rescue StandardError => e
      suggest_messages(options)
      raise e
    end
    default_command :compare

    no_commands do
      def parse(lock_file)
        Bundler::LockfileParser.new(lock_file)
      end

      def logger
        ::CompareLinkerWrapper.logger
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
