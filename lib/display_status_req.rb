# frozen_string_literal: true

require_relative 'stat_req'
require_relative 'log'

# class DisplayStatusReq
class DisplayStatusReq
  def self.display(traca_report)
    # pp traca_report
    @stat_req = StatReq.new(traca_report)
    @stat_req.build
    traca_report.each_downstream_doc do |doc|
      display_downstream_statistics(doc.name)
    end

    traca_report.each_upstream_doc do |doc|
      display_upstream_statistics(doc.name)
    end
  end

  def self.display_downstream_statistics(doc_name)
    req_stat = @stat_req.search_downstream_stat(doc_name)
    return if req_stat.nil?

    Log.display("document: #{doc_name}")
    Log.display("  coverage: #{req_stat.coverage_percent}%", color_coverage(req_stat.coverage_percent))
    Log.display("  number of requirement: #{req_stat.nb_req}")
    Log.display("  number of uncovered requirement: #{req_stat.nb_uncovered_req}",
                color_uncovered(req_stat.nb_uncovered_req))
    display_uncovered_req(req_stat) unless req_stat.nb_uncovered_req.zero?
    Log.display("  derived requirement: #{req_stat.nb_derived_percent}%")
  end

  def self.display_uncovered_req(req_stat)
    req_stat.uncovered_req_list.each do |req_id|
      Log.display("    #{req_id}")
    end
  end

  def self.display_upstream_statistics(doc_name)
    req_stat = @stat_req.search_upstream_stat(doc_name)
    return if req_stat.nil?

    Log.display("document: #{doc_name}")
    Log.display("  coverage: #{req_stat.coverage_percent}%", color_coverage(req_stat.coverage_percent))
    Log.display("  number of requirement: #{req_stat.nb_req}")
    Log.display("  number of uncovered requirement: #{req_stat.nb_uncovered_req}",
                color_uncovered(req_stat.nb_uncovered_req))
    display_uncovered_req(req_stat) unless req_stat.nb_uncovered_req.zero?
  end

  def self.color_coverage(coverage_percent)
    case coverage_percent
    when 100
      :green
    when 40..99
      :magenta
    else
      :red
    end
  end

  def self.color_uncovered(uncovered_nb)
    if uncovered_nb.zero?
      :green
    else
      :magenta
    end
  end
end
