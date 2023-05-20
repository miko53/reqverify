# frozen_string_literal: true

require 'byebug'
# class for exporting data to file
class ExportReq
  def initialize(project, filename, traca_result)
    @project = project
    @filename = filename
    @traca_result = traca_result
  end

  def write_traca_report(stat)
    # pp @traca_result
    filename = "#{@filename}.csv"
    f = File.open(filename, 'w')

    stat_index = 0
    @traca_result.each do |traca|
      f.write("name;#{traca['name']}\n")
      trace_report = traca['data']
      f.write("down;up;\n")
      trace_report.each do |traca_line|
        coverage = traca_line['cov_list']
        next if coverage.empty?

        f.write("#{traca_line['id']};")
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
      f.write(";\n")
      f.write("statistic;\n")
      f.write(";\n")
      f.write("coverage;#{stat_report['coverage_percent']}%;\n")
      f.write("\"number of requirement\";#{stat_report['nb_req']};\n")
      f.write("\"number of uncovered requirement\";#{stat_report['nb_uncovered_req']};\n")
      f.write("\"derived requirement\";#{stat_report['nb_derived_percent']}%;\n")
      stat_index += 1
    end
    f.close
  end

  def write_traca_up_report(stat)
    # pp @traca_result
    filename = "#{@filename}.csv"
    f = File.open(filename, 'w')

    stat_index = 0
    @traca_result.each do |traca|
      f.write("name;#{traca['name']}\n")
      trace_report = traca['data']
      f.write("up;down;\n")
      trace_report.each do |traca_line|
        coverage = traca_line['covered-by']
        next if coverage.empty?

        f.write("#{traca_line['id']};")
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
      f.write(";\n")
      f.write("statistic;\n")
      f.write(";\n")
      f.write("coverage;#{stat_report['coverage_percent']}%;\n")
      f.write("\"number of requirement\";#{stat_report['nb_req']};\n")
      f.write("\"number of uncovered requirement\";#{stat_report['nb_uncovered_req']};\n")
      stat_index += 1
    end
    f.close
  end
end
