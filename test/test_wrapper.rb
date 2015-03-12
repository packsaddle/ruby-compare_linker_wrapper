require_relative 'helper'

module CompareLinker
  class TestWrapper < Test::Unit::TestCase
    test 'version' do
      assert do
        !::CompareLinker::Wrapper::VERSION.nil?
      end
    end
  end
end
