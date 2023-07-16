# frozen_string_literal: true

require 'roo-xls'
require 'yaml'
require_relative 'import_plugin'

# class XlsImportRules
class XlsImportRules
  def initialize
    @req_id_regexp = []
    @req_id_column = 0
    @req_title_column = 0
    @req_text_column = 0
    @req_category_column = 0
    @req_rational_column = 0
  end

  def set_rules(rules = {})
    @req_id_regexp = rules['req_id_regexp']
    @req_id_column = rules['req_id_column']
    @req_title_column = rules['req_title_column']
    @req_text_column = rules['req_text_column']
    @req_category_column = rules['req_category_column']
    @req_rational_column = rules['req_rational_column']
    p rules.to_yaml.dump
  end

  attr_accessor :req_id_regexp, :req_id_column, :req_title_column, :req_text_column, :req_category_column,
                :req_rational_column
end

# class XlsImport
class XlsImport < ImportPlugin
  def initialize
    super
    @yaml_doc = {}
    @yaml_doc['reqs'] = []
  end

  def rules=(rule_set = {})
    @import_rules = XlsImportRules.new
    @import_rules.set_rules(rule_set)
  end

  def import(input_file, output_file)
    @xls_doc = Roo::Spreadsheet.open(input_file)
    return if @xls_doc.nil?

    parse_xls_file
    save_output_file(output_file)
    true
  end

  private

  def parse_xls_file
    sheets = @xls_doc.worksheets
    sheets.each do |sheet|
      parse_sheet(sheet)
    end
  end

  def parse_sheet(sheet)
    sheet.each do |row|
      @import_rules.req_id_regexp.each do |req_id_rule|
        if row[@import_rules.req_id_column] =~ req_id_rule
          insert_req(row)
          break
        end
      end
    end
  end

  def insert_req(row)
    req = {}
    req['req_id'] = row[@import_rules.req_id_column].strip
    req['req_title'] = row[@import_rules.req_title_column]
    req['req_text'] = row[@import_rules.req_text_column]
    insert_req_attrs(req, row)
    @yaml_doc['reqs'].append req
  end

  def insert_req_attrs(req, row)
    req_attrs = {}
    req_attrs['category'] = row[@import_rules.req_category_column]
    req_attrs['rational'] = row[@import_rules.req_rational_column]
    req['req_attrs'] = req_attrs
  end

  def save_output_file(output_file)
    File.open(output_file, 'w') do |file|
      file.write(YAML.dump(@yaml_doc))
    end
  end
end

# xls_import_rules = XlsImportRules.new
# xls_import_rules.req_id_regexp.append(/APP_*/)
# xls_import_rules.req_id_column = 0
# xls_import_rules.req_title_column = 1
# xls_import_rules.req_text_column = 2
# xls_import_rules.req_category_column = 6
# xls_import_rules.req_rational_column = 3

# import_rules = {}
# import_rules['req_id_regexp'] = []
# import_rules['req_id_regexp'].append(/APP_*/)
# import_rules['req_id_column'] = 0
# import_rules['req_title_column'] = 1
# import_rules['req_text_column'] = 2
# import_rules['req_category_column'] = 6
# import_rules['req_rational_column'] = 3

# xls = XlsImport.new
# xls.rules = import_rules
# xls.import('TEST.xls', 'test.yaml')