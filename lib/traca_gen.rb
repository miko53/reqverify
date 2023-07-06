# frozen_string_literal: true

require_relative 'project'
require_relative 'traca_report'

# class TracaGenerator
class TracaGenerator
  # @param project[Project]
  def initialize(project)
    @project = project
  end

  # @param relationship[String]
  def generate_traceability(relationship)
    upstream_docs = @project.upstream_docs(relationship)
    downstream_docs = @project.downstream_docs(relationship)
    return if check_if_loaded(upstream_docs + downstream_docs) == false

    r = TracaReport.new
    generate_traca_of_downstream_docs(r, downstream_docs, upstream_docs)
    generate_traca_of_upstream_docs(r, downstream_docs, upstream_docs)
    r
  end

  private

  def generate_traca_of_downstream_docs(traca_report, downstream_docs, upstream_docs) # rubocop:disable Metrics/MethodLength
    downstream_docs.each do |downstream_doc|
      traca_doc = TracaReportByDownstreamDoc.new
      traca_doc.doc_name = downstream_doc.doc_name
      req_list = downstream_doc.req_id_list
      req_list.each do |req_id|
        line = TracaReportDownstreamLine.new(req_id: req_id)
        cov_req_list = downstream_doc.cov_reqs_list(req_id)
        downstream_update_req_charact(req_id, cov_req_list, upstream_docs, line)
        traca_doc.append line
      end
      traca_report.append_downstream_doc(traca_doc)
    end
  end

  def downstream_update_req_charact(req_id, cov_req_list, upstream_docs, line)
    # '&' => check if nil
    cov_req_list&.each do |cov_req|
      if @project.name_for_derived_req_id?(cov_req)
        line.derived = true
      elsif check_if_req_id_exists?(cov_req, upstream_docs)
        line.append cov_req
      else
        print "warning: '#{req_id}' doesn't exist\n"
      end
    end
  end

  def generate_traca_of_upstream_docs(traca_report, downstream_docs, upstream_docs) # rubocop:disable Metrics/MethodLength
    upstream_docs.each do |upstream_doc|
      traca_doc = TracaReportByUpstreamDoc.new
      traca_doc.doc_name = upstream_doc.doc_name
      req_list = upstream_doc.req_id_list
      req_list.each do |req_id|
        line = TracaReportUpstreamLine.new(req_id: req_id)
        downstream_docs.each do |downstream_doc|
          line.concat downstream_doc.req_list_of_covered_id(req_id)
        end
        traca_doc.append line
      end
      traca_report.append_upstream_doc(traca_doc)
    end
  end

  # @param docs[Array(DocReq)]
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