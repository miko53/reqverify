# frozen_string_literal: true

require 'yaml'
require_relative 'doc_req'

# read and parsing project
class Project
  #  attr_accessor :project_file

  def initialize(filename)
    @filename = filename
    @project_file = nil
    read
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

  # search in project definition for req_id name
  # for derived requirement
  # +req_id+ String arg. to check
  def name_for_derived_req_id?(req_id)
    @project_file['derived-name'].each do |name|
      return true if name == req_id
    end
    false
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

  private

  # read the project filename, decode the YAML format
  def read
    f = read_file
    return if f.nil?

    decode_yaml_file f
    f.close
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
  def create_doc_req(docname)
    @project_file['docs'].each do |item|
      return DocReq.new(self, item['name'], item['path']) if item['name'] == docname
    end
    nil
  end
end
