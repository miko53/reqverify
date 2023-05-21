# frozen_string_literal: true

require_relative 'export_req'
require_relative 'stat_req'

# class Export
class Export
  def initialize(result)
    @result = result
  end

  def export_result
    export_downstream_results(@result[:downstream])
    export_upstream_results(@result[:upstreams])
  end

  def export_downstream_results(traca_result)
    export = ExportReq.new(@project, 'test', traca_result)
    stat = StatReq.new
    stat_report = stat.build_stat(traca_result)
    export.write_traca_report(stat_report)
  end

  def export_upstream_results(traca_result)
    export = ExportReq.new(@project, 'test_2', traca_result)
    stat = StatReq.new
    stat_report = stat.build_up_stat(traca_result)
    export.write_traca_up_report(stat_report)
  end
end