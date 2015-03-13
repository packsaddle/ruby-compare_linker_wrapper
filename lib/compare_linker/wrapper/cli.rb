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
      option :base, type: :string, default: 'origin/master'
      option :head, type: :string, default: 'HEAD'

      def compare(*_args)
        setup_logger(options)
        gemfile_locks = [
          'Gemfile.lock'
        ]
        params = {
          base: options[:base],
          head: options[:head]
        }
        access_token = ENV['OCTOKIT_ACCESS_TOKEN'] || ENV['GITHUB_ACCESS_TOKEN']
        octokit ||= Octokit::Client.new(access_token: access_token)
        formatter = ::CompareLinker::Formatter::Text.new
        git = Git.open('.')
        old_lockfile = parse(git.show(params[:base], gemfile_locks[0]))
        new_lockfile = parse(git.show(params[:head], gemfile_locks[0]))

        comparator = LockfileComparator.new
        comparator.compare(old_lockfile, new_lockfile)
        compare_links = comparator.updated_gems.map do |gem_name, gem_info|
          if gem_info[:owner].nil?
            finder = GithubLinkFinder.new(octokit)
            finder.find(gem_name)
            if finder.repo_owner.nil?
              gem_info[:homepage_uri] = finder.homepage_uri
              formatter.format(gem_info)
            else
              gem_info[:repo_owner] = finder.repo_owner
              gem_info[:repo_name] = finder.repo_name

              tag_finder = GithubTagFinder.new(octokit)
              old_tag = tag_finder.find(finder.repo_full_name, gem_info[:old_ver])
              new_tag = tag_finder.find(finder.repo_full_name, gem_info[:new_ver])

              if old_tag && new_tag
                gem_info[:old_tag] = old_tag.name
                gem_info[:new_tag] = new_tag.name
                formatter.format(gem_info)
              else
                formatter.format(gem_info)
              end
            end
          else
            formatter.format(gem_info)
          end
        end
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
