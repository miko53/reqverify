# frozen_string_literal: true

require_relative 'export_req'
require_relative 'stat_req'
require_relative 'project'

# class Traca
class Traca
  def initialize(project)
    @project = project
  end

  def generate_traceability(relationship)
    upstream_docs = @project.upstream_docs(relationship)
    downstream_docs = @project.downstream_docs(relationship)
    return if check_if_loaded(upstream_docs + downstream_docs) == false

    r = {}
    r[:downstream] = generate_traca_of_downstream_docs(downstream_docs, upstream_docs)
    r[:upstreams] = generate_traca_of_upstream_docs(downstream_docs, upstream_docs)
    r
  end

  private

  def generate_traca_of_downstream_docs(downstream_docs, upstream_docs)
    traca_by_doc = []
    downstream_docs.each do |downstream_doc|
      traca_doc = {}
      traca_doc['name'] = downstream_doc.doc_name
      traca_report = []
      req_list = downstream_doc.req_id_list
      req_list.each do |req_id|
        line = downstream_setup_default_line(req_id)
        cov_req_list = downstream_doc.cov_reqs_list(req_id)
        line = downstream_update_req_charact(req_id, cov_req_list, upstream_docs, line)
        traca_report.append line
      end
      traca_doc['data'] = traca_report
      traca_by_doc.append traca_doc
    end
    traca_by_doc
  end

  def downstream_setup_default_line(req_id)
    line = {}
    line['id'] = req_id
    line['cov_list'] = []
    line['derived'] = false
    line
  end

  def downstream_update_req_charact(req_id, cov_req_list, upstream_docs, line)
    cov_req_list&.each do |cov_req|
      if @project.name_for_derived_req_id?(cov_req)
        line['derived'] = true
      elsif check_if_req_id_exists?(cov_req, upstream_docs)
        line['cov_list'].append cov_req
      else
        print "error: '#{req_id}' doesn't exist\n"
      end
    end
    line
  end

  def generate_traca_of_upstream_docs(downstream_docs, upstream_docs)
    traca_by_doc = []
    upstream_docs.each do |upstream_doc|
      traca_doc = {}
      traca_doc['name'] = upstream_doc.doc_name
      traca_report = []
      req_list = upstream_doc.req_id_list
      req_list.each do |req_id|
        line = upstream_setup_default_line(req_id)
        downstream_docs.each do |downstream_doc|
          line['covered-by'].concat downstream_doc.req_list_of_covered_id(req_id)
        end
        traca_report.append line
      end
      traca_doc['data'] = traca_report
      traca_by_doc.append traca_doc
    end
    traca_by_doc
  end

  def upstream_setup_default_line(req_id)
    line = {}
    line['id'] = req_id
    line['covered-by'] = []
    line
  end

  def check_if_loaded(docs)
    loaded = true
    docs.each do |doc|
      loaded = false unless doc.loaded?
    end
    loaded
  end

  def check_if_req_id_exists?(cov_req_id, upstream_docs)
    upstream_docs.each do |docs|
      return true if docs.req_id_exist?(cov_req_id)
    end
    false
  end
end
