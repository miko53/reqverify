# frozen_string_literal: true

require 'yaml'
require 'reqv/doc_req'
require 'reqv/misc'

module Reqv
  # read and parsing project
  class Project
    PROJECT_VERSION = 1.0

    def initialize(filename)
      @filename = filename
      @project_file = nil
    end

    # check if project is correctly loaded
    def loaded?
      !@project_file.nil?
    end

    # provide the working dir of the project filename
    def working_dir
      File.dirname(@filename)
    end

    # provide the upstream documents (+docs_req_list+ DocReq object)
    # according to +relationship+ (String) which names the link
    # between document
    # @param relationship[String]
    # @return [Array(DocReq)]
    def upstream_docs(relationship)
      docname_list = search_upstream_docs(relationship)
      return nil if docname_list.nil?

      docs_req_list = []
      docname_list.each do |docname|
        docs_req_list.append(create_doc_req(docname))
      end
      docs_req_list
    end

    # provide the downstream documents (+docs_req_list+ DocReq object)
    # according to +relationship+ String object which names the link
    # between document
    def downstream_docs(relationship)
      docname_list = search_downstream_docs(relationship)
      return nil if docname_list.nil?

      docs_req_list = []
      docname_list.each do |docname|
        docs_req_list.append create_doc_req(docname)
      end
      docs_req_list
    end

    def doc_list
      doclist = []
      @project_file['docs'].each do |doc|
        doclist.append doc['name']
      end
      doclist
    end

    def doc_req(docname, filter)
      create_doc_req(docname, filter)
    end

    # search in project definition for req_id name
    # for derived requirement
    # +req_id+ String arg. to check
    def name_for_derived_req_id?(req_id)
      if !@project_file['derived-name'].nil?
        @project_file['derived-name'].match(req_id)
      else
        ''
      end
    end

    def docs_of(relationship)
      r = []
      @project_file['relationships'].each do |item|
        r = item['covered-by'] if item['name'] == relationship
        r += item['doc'] if item['name'] == relationship
      end
      r
    end

    def import?(docname)
      b = false
      @project_file['docs'].each do |doc|
        b = !doc['imported-from'].nil? if doc['name'] == docname
      end
      b
    end

    def input_file_exist?(docname)
      r = false
      @project_file['docs'].each do |doc|
        next unless doc['name'] == docname

        input_file = doc['imported-from']['input']
        filename = File.join(working_dir, input_file)
        r = File.exist?(filename)
      end
      r
    end

    def get_input_file(docname)
      @project_file['docs'].each do |doc|
        next unless doc['name'] == docname

        input_file = doc['imported-from']['input']
        filename = File.join(working_dir, input_file)
        return filename
      end
      nil
    end

    def output_file_exist?(docname)
      r = false
      @project_file['docs'].each do |doc|
        next unless doc['name'] == docname

        file = doc['path']
        filename = File.join(working_dir, file)
        r = File.exist?(filename)
      end
      r
    end

    def get_output_file(docname)
      @project_file['docs'].each do |doc|
        next unless doc['name'] == docname

        file = doc['path']
        filename = File.join(working_dir, file)
        return filename
      end
      nil
    end

    def input_file_date(docname)
      @project_file['docs'].each do |doc|
        next unless doc['name'] == docname

        input_file = doc['imported-from']['input']
        filename = File.join(working_dir, input_file)
        return File.mtime(filename)
      end
    end

    def output_file_date(docname)
      @project_file['docs'].each do |doc|
        next unless doc['name'] == docname

        file = doc['path']
        filename = File.join(working_dir, file)
        return File.mtime(filename)
      end
    end

    def get_handler(docname)
      @project_file['docs'].each do |doc|
        next unless doc['name'] == docname

        imported_data = doc['imported-from']
        handler = imported_data['handler']
        return handler
      end
    end

    def get_handler_options(docname)
      @project_file['docs'].each do |doc|
        next unless doc['name'] == docname

        imported_data = doc['imported-from']
        handler_rules = imported_data['handler-rules']
        return handler_rules
      end
    end

    # read the project filename, decode the YAML format
    def read
      f = read_file
      return if f.nil?

      decode_yaml_file f
      f.close
    end

    # TODO: temporary to modify with loaded and initialize function
    def build
      @project_file = {}
      @project_file['version'] = PROJECT_VERSION
    end

    def project_name=(arg)
      @project_file['name'] = arg
    end

    def project_name
      @project_file['name']
    end

    def insert_doc_raw(docname, filename)
      @project_file['docs'] = [] if @project_file['docs'].nil?
      return false if doc_exist?(docname)

      doc = {}
      doc['name'] = docname
      doc['path'] = filename
      @project_file['docs'].append doc
      true
    end

    def insert_doc_with_plugin(docname, pluginname, filename, filename_yaml)
      @project_file['docs'] = [] if @project_file['docs'].nil?
      return false if doc_exist?(docname)

      doc = {}
      doc['name'] = docname
      doc['path'] = if filename_yaml.nil?
                      default_yaml_filename(filename)
                    else
                      filename_yaml
                    end
      handler = {}

      handler['handler'] = pluginname
      handler['input'] = filename
      hander_rules = {}

      handler['handler-rules'] = hander_rules
      doc['imported-from'] = handler
      @project_file['docs'].append doc
      true
    end

    def insert_plugin_rule(docname, rulename, rulevalue, ruletype)
      return false if @project_file['docs'].nil?

      plugin_rule = get_handler_options(docname)
      return false if plugin_rule.nil?

      plugin_rule[rulename] = if ruletype.nil?
                                if rulevalue.integer?
                                  rulevalue.to_i
                                else
                                  rulevalue
                                end
                              else
                                insert_plugin_value_according_type(rulevalue, ruletype)
                              end
    end

    def insert_relationships(name, up_docs, down_docs)
      @project_file['relationships'] = [] if @project_file['relationships'].nil?

      relationship = {}
      relationship['name'] = name
      relationship['doc'] = up_docs
      relationship['covered-by'] = down_docs

      found, i = relationship_exist?(name)
      if found == false
        @project_file['relationships'].append relationship
      else
        @project_file['relationships'][i] = relationship
      end
    end

    def insert_derived_name(regexpression)
      @project_file['derived-name'] = Regexp.new(regexpression)
    end

    def write
      File.open(@filename, 'w') do |file|
        file.write(YAML.dump(@project_file))
      end
    end

    private

    def relationship_exist?(name)
      found = false
      i = 0
      @project_file['relationships'].each do |r|
        if r['name'] == name
          found = true
          break
        end
        i += 1
      end
      [found, i]
    end

    def insert_plugin_value_according_type(rulevalue, ruletype)
      case ruletype
      when 'Integer'
        rulevalue.to_i
      when 'String'
        rulevalue
      when 'RegExp'
        Regexp.new(rulevalue)
      else
        Log.error('unknown type given')
      end
    end

    def default_yaml_filename(filename)
      "#{File.basename(filename).chomp(File.extname(filename))}.yaml"
    end

    def doc_exist?(docname)
      r = false
      @project_file['docs'].each do |doc|
        if doc['name'] == docname
          r = true
          break
        end
      end
      r
    end

    # read the project filename, decode the YAML format
    # +@filename+ => String path of file
    def read_file
      begin
        f = File.open(@filename, 'r')
      rescue StandardError => e
        puts "Can not open file #{@filename}, #{e}"
        f = nil
      end
      f
    end

    # decode the YAML format
    # +f+ => opened file
    # +@project_file+ => set to nil if not correctly decoded
    def decode_yaml_file(file)
      @project_file = YAML.safe_load file, permitted_classes: [Regexp]
      @project_file = nil if @project_file['version'].nil? || @project_file['version'] != PROJECT_VERSION
    rescue StandardError => e
      @project_file = nil
      puts "wrong file format, #{e}"
    end

    # search upstream document acording to +relationship+ (String)
    # return an Array of String
    def search_upstream_docs(relationship)
      @project_file['relationships'].each do |item|
        return item['covered-by'] if item['name'] == relationship
      end
      nil
    end

    # search downstream document acording to +relationship+ (String)
    # return an Array of String
    def search_downstream_docs(relationship)
      @project_file['relationships'].each do |item|
        return item['doc'] if item['name'] == relationship
      end
      nil
    end

    # create and return DocReq object  according to +docname+ (String)
    # DocReq read and load YAML document
    # @return [DocReq]
    def create_doc_req(docname, filter = nil)
      @project_file['docs'].each do |item|
        return DocReq.new(self, item['name'], item['path'], filter) if item['name'] == docname
      end
      nil
    end
  end
end
