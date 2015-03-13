require 'logger'

require 'compare_linker/wrapper/version'

module CompareLinker
  module Wrapper
    ISSUE_URL = 'https://github.com/packsaddle/ruby-compare_linker-wrapper/issues/new'
    def self.default_logger
      logger = Logger.new(STDERR)
      logger.progname = "CompareLinker::Wrapper/#{VERSION}"
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
end
