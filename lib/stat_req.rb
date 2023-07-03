# frozen_string_literal: true

# class StatDownstreamReq
class StatDownstreamReq
  attr_accessor :nb_req, :nb_uncovered_req, :uncovered_req_including_derived, :doc_name

  def coverage_percent
    100 - @nb_uncovered_req * 100 / @nb_req
  end

  def coverage_including_derived_percent
    100 - @uncovered_req_including_derived * 100 / @nb_req
  end

  def nb_derived_percent
    @uncovered_req_including_derived * 100 / @nb_req
  end
end

# class StatUpstreamReq
class StatUpstreamReq
  attr_accessor :nb_req, :nb_uncovered_req, :doc_name

  def coverage_percent
    100 - nb_uncovered_req * 100 / nb_req
  end
end

# class StatReq for statistical about requirement
class StatReq
  def initialize(traca_report)
    @traca_report = traca_report
    @downstream_stat = []
    @upstream_stat = []
  end

  def build
    build_downstream_stat
    build_upstream_stat
  end

  def search_downstream_stat(doc_name)
    @downstream_stat.each do |req_downstream_stat|
      return req_downstream_stat if req_downstream_stat.doc_name == doc_name
    end
  end

  def search_upstream_stat(doc_name)
    @upstream_stat.each do |req_upstream_stat|
      return req_upstream_stat if req_upstream_stat.doc_name == doc_name
    end
  end

  private

  def build_downstream_stat
    @traca_report.each_downstream_doc do |downstream_doc|
      nb_total_req = 0
      uncovered_req_including_derived = 0
      uncovered_req = 0
      downstream_doc.each_req_line do |req|
        nb_total_req += 1
        uncovered_req_including_derived += 1 if req.covers_empty? && req.derived?
        uncovered_req if req.covers_empty? && req.derived? == false
      end
      result = StatDownstreamReq.new
      result.doc_name = downstream_doc.name
      result.nb_req = nb_total_req
      result.nb_uncovered_req = uncovered_req
      result.uncovered_req_including_derived = uncovered_req_including_derived
      @downstream_stat << result
    end
  end

  def build_upstream_stat
    @traca_report.each_upstream_doc do |upstream_doc|
      nb_total_req = 0
      uncovered_req = 0
      upstream_doc.each_req_line do |req|
        nb_total_req += 1
        uncovered_req if req.covered_empty?
      end
      result = StatUpstreamReq.new
      result.doc_name = upstream_doc.name
      result.nb_req = nb_total_req
      result.nb_uncovered_req = uncovered_req
      @upstream_stat << result
    end
  end
end
