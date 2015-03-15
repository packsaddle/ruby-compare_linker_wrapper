module CompareLinkerWrapper
  class Linker
    attr_accessor :git_path, :git_options
    def initialize(git_path = '.', git_options = {})
      @git_path = git_path
      @git_options = git_options
    end

    def access_token
      ENV['OCTOKIT_ACCESS_TOKEN'] || ENV['GITHUB_ACCESS_TOKEN']
    end

    def client
      @client ||= ::Octokit::Client.new(access_token: access_token)
    end

    def git
      @git ||= Git.open(@git_path, @git_options)
    end

    def link(params)
      formatter = add_formatter(params[:formatter])
      comments = []

      params[:file].each do |gemfile_lock|
        old_lockfile = parse(git.show(params[:base], gemfile_lock))
        new_lockfile = parse(git.show(params[:head], gemfile_lock))

        comparator = ::CompareLinker::LockfileComparator.new
        comparator.compare(old_lockfile, new_lockfile)
        compare_links = comparator.updated_gems.map do |gem_name, gem_info|
          if gem_info[:owner].nil?
            finder = ::CompareLinker::GithubLinkFinder.new(client)
            finder.find(gem_name)
            if finder.repo_owner.nil?
              gem_info[:homepage_uri] = finder.homepage_uri
              formatter.format(gem_info)
            else
              gem_info[:repo_owner] = finder.repo_owner
              gem_info[:repo_name] = finder.repo_name

              tag_finder = ::CompareLinker::GithubTagFinder.new(client)
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
        comments << compare_links
      end
      comments
    end

    def add_formatter(formatter_class)
      formatter = Formatter.add_formatter(formatter_class) if formatter_class
      fail NoFormatterError unless formatter
      logger.info('use formatter')
      logger.info(formatter)
      formatter
    end

    def logger
      ::CompareLinkerWrapper.logger
    end

    def parse(lock_file)
      Bundler::LockfileParser.new(lock_file)
    end
  end
end
