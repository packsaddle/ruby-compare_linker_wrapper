require 'logger'
require 'git'
require 'bundler'
require 'octokit'
require 'compare_linker'

require 'compare_linker_wrapper/error'
require 'compare_linker_wrapper/formatter'
require 'compare_linker_wrapper/linker'
require 'compare_linker_wrapper/version'

module CompareLinkerWrapper
  ISSUE_URL = 'https://github.com/packsaddle/ruby-compare_linker_wrapper/issues/new'
  def self.default_logger
    logger = Logger.new(STDERR)
    logger.progname = "CompareLinkerWrapper/#{VERSION}"
    logger.level = Logger::WARN
    logger
  end

  def self.logger
    return @logger if @logger
    @logger = default_logger
  end

  class << self
    attr_writer :logger
  end
end
