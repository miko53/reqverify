# frozen_string_literal: true

require 'reqv/plugins/export'
require 'reqv/stat_req'

module Reqv
  # class for exporting data to file
  class CsvExport < Export
    def export_traca_report(project:, relationship:, report:, output_folder:, output_file:)
      @output_folder = output_folder
      @output_file = output_file
      @traca_report = report
      @stat_req = StatReq.new(@traca_report)
      @stat_req.build

      @project = project
      @relationship = relationship
      # @upstream_docs = @project.upstream_docs(@relationship)
      @downstream_docs = @project.downstream_docs(@relationship)

      write_downstream_report
      write_upstream_report
      write_derived_report
      true
    end

    private

    def write_downstream_report
      @traca_report.each_downstream_doc do |traca_downstream_doc|
        filename = File.join(@output_folder, "traca_#{traca_downstream_doc.name}.csv")
        f = File.open(filename, 'w')
        f.write("name;#{traca_downstream_doc.name}\n")
        f.write("down;up;\n")
        traca_downstream_doc.each_req_line do |traca_line|
          coverage = traca_line.covers_req_list
          next if coverage.empty?

          f.write("#{traca_line.req_id};")
          l = ''
          if coverage.length == 1
            l = coverage[0]
          else
            coverage.each do |req_id|
              if l.empty?
                l = "\"#{req_id}"
              else
                l += "\n#{req_id}"
              end
            end
            l += '"'
          end
          f.write("#{l};\n")
        end
        write_downstream_statistics(f, traca_downstream_doc.name)
        f.close
      end
    end

    def write_downstream_statistics(file, doc_name)
      req_stat = @stat_req.search_downstream_stat(doc_name)
      return if req_stat.nil?

      file.write(";\n")
      file.write("statistic;\n")
      file.write(";\n")
      file.write("coverage;#{req_stat.coverage_percent}%;\n")
      file.write("\"number of requirement\";#{req_stat.nb_req};\n")
      file.write("\"number of uncovered requirement\";#{req_stat.nb_uncovered_req};\n")
      file.write("\"derived requirement\";#{req_stat.nb_derived_percent}%;\n")
    end

    def write_derived_report
      filename = File.join(@output_folder, 'traca_derived_report.csv')
      f = File.open(filename, 'w')
      f.write("requirement;rationale;\n")
      @traca_report.each_downstream_doc do |traca_downstream_doc|
        traca_downstream_doc.each_req_line do |traca_line|
          next if traca_line.derived? == false

          req_data = get_requirement_characteristics(@downstream_docs, traca_line.req_id)
          rational = get_rational(req_data)
          req_line = "#{traca_line.req_id} - #{req_data['req_title']}"
          f.write("#{req_line};\"#{rational}\";\n")
        end
      end
      f.close
    end

    def write_upstream_report
      @traca_report.each_upstream_doc do |traca_upstream_doc|
        filename = File.join(@output_folder, "traca_#{traca_upstream_doc.name}.csv")
        f = File.open(filename, 'w')
        f.write("name;#{traca_upstream_doc.name}\n")
        f.write("up;down;\n")
        traca_upstream_doc.each_req_line do |traca_line|
          coverage = traca_line.covered_by_list
          next if coverage.empty?

          f.write("#{traca_line.req_id};")
          l = ''
          if coverage.length == 1
            l = coverage[0]
          else
            coverage.each do |req_id|
              if l.empty?
                l = "\"#{req_id}"
              else
                l += "\n#{req_id}"
              end
            end
            l += '"'
          end
          f.write("#{l};\n")
        end
        # pp stat
        write_upstream_statistics(f, traca_upstream_doc.name)
        f.close
      end
    end

    def write_upstream_statistics(file, doc_name)
      req_stat = @stat_req.search_upstream_stat(doc_name)
      return if req_stat.nil?

      file.write(";\n")
      file.write("statistic;\n")
      file.write(";\n")
      file.write("coverage;#{req_stat.coverage_percent}%;\n")
      file.write("\"number of requirement\";#{req_stat.nb_req};\n")
      file.write("\"number of uncovered requirement\";#{req_stat.nb_uncovered_req};\n")
    end

    def get_requirement_characteristics(doc_array, req_id)
      doc_array.each do |doc|
        req_data = doc.get_req_characteristics(req_id)
        return req_data unless req_data.nil?
      end
      nil
    end

    def get_rational(req_data)
      h = req_data['req_attrs']
      return h['rationale'] unless h['rationale'].nil?

      ''
    end
  end
end
