# frozen_string_literal: true

require 'reqv/plugins/export'
require 'reqv/stat_req'
require 'caxlsx'

module Reqv
  # class XlsxExport
  class XlsxExport < Export
    CELL_HEIGHT = 15

    def export_traca_report(project:, relationship:, report:, output_folder:, output_file:)
      @output_folder = output_folder
      @output_file = output_file
      @traca_report = report
      @stat_req = StatReq.new(@traca_report)
      @stat_req.build

      @project = project
      @relationship = relationship
      @upstream_docs = @project.upstream_docs(@relationship)
      @downstream_docs = @project.downstream_docs(@relationship)

      p = Axlsx::Package.new
      p.use_shared_strings = true
      @workbook = p.workbook
      @wrap_text = @workbook.styles.add_style({ alignment: { vertical: :center, wrap_text: true } })
      write_downstream_report
      write_upstream_report

      p.serialize(File.join(@output_folder, @output_file))
    end

    private

    def write_downstream_report
      @traca_report.each_downstream_doc do |traca_downstream_doc|
        sheet = @workbook.add_worksheet(name: traca_downstream_doc.name)
        sheet.add_row %w[down up]
        traca_downstream_doc.each_req_line do |traca_line|
          coverage = traca_line.covers_req_list
          next if coverage.empty?

          req_data = get_requirement_characteristics(@downstream_docs, traca_line.req_id)
          req_line = "#{traca_line.req_id} - #{req_data['req_title']}"
          coverage_line = build_coverage_req_line(@upstream_docs, coverage)
          sheet.add_row [req_line, coverage_line.join("\n")], style: @wrap_text, height: CELL_HEIGHT * coverage.size
        end
        write_downstream_statistics(sheet, traca_downstream_doc.name)
        sheet.to_xml_string
      end
    end

    def build_coverage_req_line(doc_array, coverage_array)
      coverage_line = []
      coverage_array.each do |req|
        req_data = get_requirement_characteristics(doc_array, req)
        coverage_line.push "#{req} - #{req_data['req_title']}"
      end
      coverage_line
    end

    def write_downstream_statistics(sheet, doc_name)
      req_stat = @stat_req.search_downstream_stat(doc_name)
      return if req_stat.nil?

      sheet.add_row [' ']
      sheet.add_row ['statistic']
      sheet.add_row [' ']

      sheet.add_row ['coverage', "#{req_stat.coverage_percent}%"]
      sheet.add_row ['number of requirement', req_stat.nb_req]
      sheet.add_row ['number of uncovered requirement', req_stat.nb_uncovered_req]
      sheet.add_row ['derived requirement', "#{req_stat.nb_derived_percent}%"]
    end

    def write_upstream_report
      @traca_report.each_upstream_doc do |traca_upstream_doc|
        sheet = @workbook.add_worksheet(name: traca_upstream_doc.name)
        sheet.add_row %w[up down]
        traca_upstream_doc.each_req_line do |traca_line|
          coverage = traca_line.covered_by_list
          next if coverage.empty?

          req_data = get_requirement_characteristics(@upstream_docs, traca_line.req_id)
          req_line = "#{traca_line.req_id} - #{req_data['req_title']}"
          coverage_line = build_coverage_req_line(@downstream_docs, coverage)
          sheet.add_row [req_line, coverage_line.join("\n")], style: @wrap_text, height: CELL_HEIGHT * coverage.size
        end
        write_upstream_statistics(sheet, traca_upstream_doc.name)
        sheet.to_xml_string
      end
    end

    def write_upstream_statistics(sheet, doc_name)
      req_stat = @stat_req.search_upstream_stat(doc_name)
      return if req_stat.nil?

      sheet.add_row [' ']
      sheet.add_row ['statistic']
      sheet.add_row [' ']
      sheet.add_row ['coverage', "#{req_stat.coverage_percent}%"]
      sheet.add_row ['number of requirement', req_stat.nb_req]
      sheet.add_row ['number of uncovered requirement', req_stat.nb_uncovered_req]
    end

    def get_requirement_characteristics(doc_array, req_id)
      doc_array.each do |doc|
        req_data = doc.get_req_characteristics(req_id)
        return req_data unless req_data.nil?
      end
      nil
    end
  end
end
