# frozen_string_literal: true

require 'docx'
require 'yaml'
require_relative '../../lib/import_plugins/import_plugin'

# clasx DocStyleRules
class DocxStyleRules
  def initialize(name = nil)
    @name = name
    @is_begin = false
  end
  attr_accessor :name, :is_begin
end

# class DocxImportRules
class DocxImportRules
  def initialize
    @rules = []
    @req_id_style = DocxStyleRules.new
    @req_id_style.is_begin = true
    @req_title_style = DocxStyleRules.new
    @req_text_style = DocxStyleRules.new
    @req_cov_style = DocxStyleRules.new
    @req_attributes_style = DocxStyleRules.new
    @req_end_style = DocxStyleRules.new
  end

  def set_rules(rules = {})
    @req_id_style = DocxStyleRules.new
    @req_id_style.name = rules['req_id_style_name']
    @req_id_style.is_begin = true

    @req_title_style = DocxStyleRules.new
    @req_title_style.name = rules['req_title_style_name']

    @req_text_style = DocxStyleRules.new
    @req_text_style.name = rules['req_text_style_name']

    @req_cov_style = DocxStyleRules.new
    @req_cov_style.name = rules['req_cov_style_name']

    @req_attributes_style = DocxStyleRules.new
    @req_attributes_style.name = rules['req_attributes_style_name']

    @req_end_style = DocxStyleRules.new
    @req_end_style.name = rules['req_end_style_name']
  end

  attr_accessor :req_id_style, :req_title_style, :req_text_style, :req_cov_style, :req_attributes_style, :req_end_style
end

# class DocxImport
class DocxImportMyRules < ImportPlugin
  def rules=(rule_set = {})
    @import_rules = DocxImportRules.new
    @import_rules.set_rules(rule_set)
  end

  def import(input_file, output_file)
    @docx = Docx::Document.open(input_file)
    return if @docx.nil?

    parse_doc
    #pp @yaml_doc
    save_output_file(output_file)
    true
  end

  def parse_doc  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity
    @current_req = {}
    @current_req_attrs = {}
    @docx.each_paragraph do |p|
      case p.style
      when @import_rules.req_id_style.name
        insert_req_id(p.text)
      when @import_rules.req_text_style.name
        insert_req_text(p.text)
      when @import_rules.req_title_style.name
        insert_req_title(p.text)
      when @import_rules.req_cov_style.name
        insert_req_cov(p.text)
      when @import_rules.req_attributes_style.name
        insert_req_attributes(p.text)
      when !@import_rules.req_end_style.name.nil? && @import_rules.req_end_style.name
        insert_req_end(p.text)
      end
    end
  end

  def insert_req_id(text)
    if @import_rules.req_id_style.is_begin == true && !@current_req['req_id'].nil?
      @current_req['req_attrs'] = @current_req_attrs
      @yaml_doc['reqs'].append @current_req
      @current_req = {}
      @current_req_attrs = {}
    end
    @current_req['req_id'] = text
  end

  def insert_req_text(text)
    if @current_req['req_text'].nil?
      @current_req['req_text'] = text
    else
      @current_req['req_text'].concat('\n', text)
    end
  end

  def insert_req_title(text)
    @current_req['req_title'] = text
  end

  def insert_req_cov(text)
    t = text.split(',')
    t.map(&:strip!)
    @current_req['req_cov'] = t
  end

  def insert_req_attributes(text)
    t = text.split(/[:\t]/)
    @current_req_attrs[t[0].strip.downcase] = t[1].strip
  end

  def insert_req_end(text); end
end
