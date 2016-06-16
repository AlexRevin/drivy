require "json"

module Util
  class Writer
    class << self
      def write file_name
        receiver = {}
        yield receiver if block_given?

        File.open file_name, "w" do |file|
          file.write JSON.pretty_generate(receiver)
        end
      end
    end
  end
end