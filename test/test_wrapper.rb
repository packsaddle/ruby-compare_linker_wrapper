require_relative 'helper'

module CompareLinkerWrapper
  class TestWrapper < Test::Unit::TestCase
    test 'version' do
      assert do
        !::CompareLinkerWrapper::VERSION.nil?
      end
    end
  end
end
