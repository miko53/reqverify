# frozen_string_literal: true

# class StatDownstreamReq
class StatDownstreamReq
  def initialize
    @nb_req = 0
    @nb_uncovered_req = 0
    @doc_name = nil
    @uncovered_req_list = []
    @nb_derived_req = 0
    @derived_req_list = []
  end

  attr_accessor :nb_req, :nb_uncovered_req, :doc_name, :uncovered_req_list,
                :nb_derived_req, :derived_req_list

  def coverage_percent
    100 - @nb_uncovered_req * 100 / @nb_req
  end

  def nb_derived_percent
    @nb_derived_req * 100 / @nb_req
  end
end

# class StatUpstreamReq
class StatUpstreamReq
  def initialize
    @nb_req = 0
    @nb_uncovered_req = 0
    @doc_name = nil
    @uncovered_req_list = []
  end

  attr_accessor :nb_req, :nb_uncovered_req, :doc_name, :uncovered_req_list

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
    Log.debug_pp @downstream_stat
    Log.debug_pp @upstream_stat
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
      result = StatDownstreamReq.new
      result.doc_name = downstream_doc.name
      downstream_doc.each_req_line do |req|
        result.nb_req += 1
        insert_derived(result, req)
        insert_uncovered(result, req)
      end
      @downstream_stat << result
    end
  end

  def insert_derived(downstream_stat, req)
    return unless req.derived?

    downstream_stat.nb_derived_req += 1
    downstream_stat.derived_req_list.append req.req_id
  end

  def insert_uncovered(downstream_stat, req)
    return unless req.covers_empty? && req.derived? == false

    downstream_stat.nb_uncovered_req += 1
    downstream_stat.uncovered_req_list.append req.req_id
  end

  def build_upstream_stat
    @traca_report.each_upstream_doc do |upstream_doc|
      result = StatUpstreamReq.new
      result.doc_name = upstream_doc.name
      upstream_doc.each_req_line do |req|
        result.nb_req += 1
        insert_uncovered_ignored_derived(result, req)
      end
      @upstream_stat << result
    end
  end

  def insert_uncovered_ignored_derived(upstream_stat, req)
    return unless req.covered_empty?

    upstream_stat.nb_uncovered_req += 1
    upstream_stat.uncovered_req_list.append req.req_id
  end
end
