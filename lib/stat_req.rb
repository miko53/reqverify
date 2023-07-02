# frozen_string_literal: true

# class StatReq for statistical about requirement
class StatReq
  def build_downstream_stat(traca_report)
    traca_stat = []
    traca_report.each_downstream_doc do |downstream_doc|
      nb_total_req = 0
      uncovered_req_including_derived = 0
      uncovered_req = 0
      downstream_doc.each_req_line do |req|
        nb_total_req += 1
        uncovered_req_including_derived += 1 if req.covers_empty? && req.derived?
        uncovered_req if req.covers_empty? && req.derived? == false
      end
      result = {}
      result['nb_req'] = nb_total_req
      result['nb_uncovered_req'] = uncovered_req
      result['uncovered_req_including_derived'] = uncovered_req_including_derived
      result['coverage_percent'] = 100 - uncovered_req * 100 / nb_total_req
      result['coverage_including_derived_percent'] = 100 - uncovered_req_including_derived * 100 / nb_total_req
      result['nb_derived_percent'] = uncovered_req_including_derived * 100 / nb_total_req
      traca_stat << result
    end
    traca_stat
  end

  def build_upstream_stat(traca_report)
    traca_stat = []
    traca_report.each_upstream_doc do |upstream_doc|
      nb_total_req = 0
      uncovered_req = 0
      upstream_doc.each_req_line do |req|
        nb_total_req += 1
        uncovered_req if req.covered_empty?
      end
      result = {}
      result['nb_req'] = nb_total_req
      result['nb_uncovered_req'] = uncovered_req
      result['coverage_percent'] = 100 - uncovered_req * 100 / nb_total_req
      traca_stat << result
    end
    traca_stat
  end
end
