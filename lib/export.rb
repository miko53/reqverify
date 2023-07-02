# frozen_string_literal: true

require_relative 'export_csv_req'
require_relative 'stat_req'
require_relative 'traca_report'

# class Export
class Export
  def initialize(result, output_folder)
    @result = result
    @output_folder = output_folder
  end

  def export_result(traca_report)
    export_downstream_results(traca_report)
    export_upstream_results(traca_report)
  end

  def export_downstream_results(traca_report)
    export = ExportCsvReq.new(@output_folder, traca_report)
    stat = StatReq.new
    stat_report = stat.build_downstream_stat(traca_report)
    export.write_downstream_report(stat_report)
    Log.debug_pp stat_report
  end

  def export_upstream_results(traca_report)
    export = ExportCsvReq.new(@output_folder, traca_report)
    stat = StatReq.new
    stat_report = stat.build_upstream_stat(traca_report)
    export.write_upstream_report(stat_report)
    Log.debug_pp stat_report
  end
end
