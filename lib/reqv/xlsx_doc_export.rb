# frozen_string_literal: true

require 'caxlsx'

module Reqv
  # class XlsxDocExport
  class XlsxDocExport
    CELL_HEIGHT = 15

    def initialize(doc_req)
      @doc = doc_req
    end

    def generate(output_folder:, output_file:)
      @output_folder = output_folder
      @output_file = output_file
      p = Axlsx::Package.new
      p.use_shared_strings = true
      @workbook = p.workbook
      @wrap_text = @workbook.styles.add_style({ alignment: { vertical: :center, wrap_text: true } })
      write_doc
      p.serialize(File.join(@output_folder, @output_file))
    end

    private

    def write_doc
      sheet = @workbook.add_worksheet(name: 'requirement_list')
      row = []
      row.append 'ID'
      row.append 'title'
      row.append 'text'
      row.append 'coverage'
      row |= @doc.attribute_list
      # p row
      sheet.add_row row
      @doc.each_req do |req|
        req_attrs = req['req_attrs']
        list_attr = req_attrs.values
        sheet.add_row [req['req_id'], req['req_title'], req['req_text'], req['req_cov'].join(', '), list_attr].flatten,
                      style: @wrap_text
      end
      sheet.to_xml_string
    end
  end
end
