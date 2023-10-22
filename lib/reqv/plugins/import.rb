# frozen_string_literal: true

module Reqv
  # class Import
  class Import
    def initialize
      @yaml_doc = {}
      @yaml_doc['reqs'] = []
    end

    def save_output_file(output_file)
      dirname = File.dirname output_file
      Dir.mkdir dirname unless Dir.exist? dirname

      File.open(output_file, 'w') do |file|
        file.write(YAML.dump(@yaml_doc))
      end
    end

    def rules=(rule_set = {}); end

    def import(input_file, output_file); end
  end
end
