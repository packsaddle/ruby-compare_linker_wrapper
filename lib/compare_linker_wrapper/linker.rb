module CompareLinkerWrapper
  class Linker
    def link(params)
      access_token = ENV['OCTOKIT_ACCESS_TOKEN'] || ENV['GITHUB_ACCESS_TOKEN']
      octokit ||= ::Octokit::Client.new(access_token: access_token)
      formatter = add_formatter(options)

      git = Git.open('.')
      gemfile_locks.each do |gemfile_lock|
        old_lockfile = parse(git.show(params[:base], gemfile_lock))
        new_lockfile = parse(git.show(params[:head], gemfile_lock))

        comparator = ::CompareLinker::LockfileComparator.new
        comparator.compare(old_lockfile, new_lockfile)
        compare_links = comparator.updated_gems.map do |gem_name, gem_info|
          if gem_info[:owner].nil?
            finder = ::CompareLinker::GithubLinkFinder.new(octokit)
            finder.find(gem_name)
            if finder.repo_owner.nil?
              gem_info[:homepage_uri] = finder.homepage_uri
              formatter.format(gem_info)
            else
              gem_info[:repo_owner] = finder.repo_owner
              gem_info[:repo_name] = finder.repo_name

              tag_finder = ::CompareLinker::GithubTagFinder.new(octokit)
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
        puts compare_links
      end
    end
    def add_formatter(options)
      formatter = Formatter.add_formatter(options[:formatter]) if options[:formatter]
      fail NoFormatterError unless formatter
      logger.info('use formatter')
      logger.info(formatter)
      formatter
    end
  end
end
