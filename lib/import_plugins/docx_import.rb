# frozen_string_literal: true

require 'docx'
require 'yaml'
require_relative 'import_plugin'

# clasx DocStyleRules
class DocxStyleRules
  def initialize
    @name = ''
    @has_multiple_values = false
    @is_array = false
  end
end

# class DocxImportRules
class DocxImportRules
  def initialize
    @req_id_style = 'REQ_ID'
    @req_cov_style = 'REQ_COV'
  end

  def set_rules(rules = {}); end
end

# class DocxImport
class DocxImport < ImportPlugin
  def initialize
    super
    @yaml_doc = {}
    @yaml_doc['reqs'] = []
    p 'docx import'
  end

  def rules=(rule_set = {})
    @import_rules = DocxImportRules.new
    @import_rules.set_rules(rule_set)
  end

  def import(input_file, _output_file)
    @docx = Docx::Document.open(input_file)
    return if @docx.nil?

    parse_doc
    pp @yaml_doc
    # save_output_file(output_file)
    true
  end

  def parse_doc
    req = {}
    req_attrs = {}
    @docx.each_paragraph do |p|
      puts "#{p.text} (#{p.style})"
      if p.style == 'REQ_ID'
        unless req['req_id'].nil?
          p 'append'
          req['req_attrs'] = req_attrs
          @yaml_doc['reqs'].append req
          req = {}
          req_attrs = {}
        end

        req['req_id'] = p.text
      end
      req['req_title'] = p.text if p.style == 'REQ_TITLE'
      if p.style == 'REQ_TEXT'
        if req['req_text'].nil?
          req['req_text'] = p.text
        else
          req['req_text'].concat('\n', p.text)
        end
      end

      if p.style == 'REQ_COV'
        t = p.text.split(',')
        t.map(&:strip!)
        req['req_cov'] = t
      end

      next unless p.style == 'REQ_ATTRIBUTES'

      t = p.text.split(/[:\t]/)
      pp t
      req_attrs[t[0].strip.downcase] = t[1].strip
    end
  end
end
