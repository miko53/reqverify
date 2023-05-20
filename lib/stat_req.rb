# frozen_string_literal: true

# class StatReq for statistical about requirement
class StatReq
  def build_stat(traca_result)
    traca_stat = []
    traca_result.each do |srs_traca|
      nb_total_req = 0
      uncovered_req_including_derived = 0
      uncovered_req = 0
      trace_data = srs_traca['data']
      trace_data.each do |req|
        nb_total_req += 1
        uncovered_req_including_derived += 1 if req['cov_list'].empty? && req['derived'] == true
        uncovered_req if req['cov_list'].empty? && req['derived'] == false
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

  def build_up_stat(traca_result)
    traca_stat = []
    traca_result.each do |srs_traca|
      nb_total_req = 0
      uncovered_req = 0
      trace_data = srs_traca['data']
      trace_data.each do |req|
        nb_total_req += 1
        uncovered_req if req['covered-by'].empty?
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
