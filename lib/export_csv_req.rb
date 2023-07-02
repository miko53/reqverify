# frozen_string_literal: true

# class for exporting data to file
class ExportCsvReq
  def initialize(output_folder, traca_report)
    @output_folder = output_folder
    @traca_report = traca_report
  end

  def write_downstream_report(stat)
    stat_index = 0
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
      stat_report = stat[stat_index]
      write_upstream_statistics(f, stat_report)
      stat_index += 1
      f.close
    end
  end

  def write_upstream_statistics(file, stat_report)
    file.write(";\n")
    file.write("statistic;\n")
    file.write(";\n")
    file.write("coverage;#{stat_report['coverage_percent']}%;\n")
    file.write("\"number of requirement\";#{stat_report['nb_req']};\n")
    file.write("\"number of uncovered requirement\";#{stat_report['nb_uncovered_req']};\n")
    file.write("\"derived requirement\";#{stat_report['nb_derived_percent']}%;\n")
  end

  def write_upstream_report(stat)
    # pp @traca_result
    stat_index = 0
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
      stat_report = stat[stat_index]
      write_downstream_statistics(f, stat_report)
      stat_index += 1
      f.close
    end
  end

  def write_downstream_statistics(file, stat_report)
    file.write(";\n")
    file.write("statistic;\n")
    file.write(";\n")
    file.write("coverage;#{stat_report['coverage_percent']}%;\n")
    file.write("\"number of requirement\";#{stat_report['nb_req']};\n")
    file.write("\"number of uncovered requirement\";#{stat_report['nb_uncovered_req']};\n")
  end
end
