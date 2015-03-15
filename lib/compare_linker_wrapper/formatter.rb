module CompareLinkerWrapper
  module Formatter
    def self.add_formatter(formatter_type, output = nil)
      formatter = custom_formatter_class(formatter_type)
      formatter.new
    end

    # Copy from rubocop:
    # lib/rubocop/formatter/formatter_set.rb
    def self.custom_formatter_class(specified_class_name)
      constant_names = specified_class_name.split('::')
      constant_names.shift if constant_names.first.empty?
      constant_names.reduce(Object) do |namespace, constant_name|
        namespace.const_get(constant_name, false)
      end
    end
  end
end
