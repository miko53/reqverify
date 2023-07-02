# frozen_string_literal: true

# class TracaReportUpstreamLine
class TracaReportUpstreamLine
  def initialize(req_id:)
    @line = {}
    @line['id'] = req_id
    @line['covered-by'] = []
  end

  def concat(cov_list)
    @line['covered-by'].concat cov_list
  end

  def covered_empty?
    @line['covered-by'].empty?
  end

  def covered_by_list
    @line['covered-by']
  end

  def req_id
    @line['id']
  end
end

# class TracaReportDownstreamLine
class TracaReportDownstreamLine
  def initialize(req_id:)
    @line = {}
    @line['id'] = req_id
    @line['derived'] = false
    @line['covers'] = []
  end

  def derived=(is_derived)
    @line['derived'] = is_derived
  end

  def append(covered_req)
    @line['covers'].append covered_req
  end

  def covers_empty?
    @line['covers'].empty?
  end

  def covers_req_list
    @line['covers']
  end

  def req_id
    @line['id']
  end

  def derived?
    @line['derived']
  end
end

# class TracaReportByUpstreamDoc
class TracaReportByUpstreamDoc
  def initialize
    @upstream_report = {}
    @upstream_report['data'] = []
  end

  def doc_name=(doc_name)
    @upstream_report['name'] = doc_name
  end

  def name
    @upstream_report['name']
  end

  def append(traca_line)
    @upstream_report['data'].append traca_line
  end

  def each_req_line(&block)
    @upstream_report['data'].each(&block)
  end
end

# class TracaReportByDownstreamDoc
class TracaReportByDownstreamDoc
  def initialize
    @downstream_report = {}
    @downstream_report['data'] = []
  end

  def doc_name=(doc_name)
    @downstream_report['name'] = doc_name
  end

  def name
    @downstream_report['name']
  end

  def append(traca_line)
    @downstream_report['data'].append traca_line
  end

  def traca_lines
    @downstream_report['data']
  end

  def each_req_line(&block)
    @downstream_report['data'].each(&block)
  end
end

# class TracaReport
# result of traca generation
class TracaReport
  def initialize
    @traca_report = {}
    @traca_report[:upstreams] = []
    @traca_report[:downstreams] = []
  end

  # @param downstream_doc[TracaReportByDownstreamDoc]
  def append_downstream_doc(downstream_doc)
    @traca_report[:downstreams].append(downstream_doc)
  end

  # @param upstream_doc[TracaReportByUpstreamDoc]
  def append_upstream_doc(upstream_doc)
    @traca_report[:upstreams].append(upstream_doc)
  end

  # iterator on each downstream document
  def each_downstream_doc(&block)
    @traca_report[:downstreams].each(&block)
  end

  def each_upstream_doc(&block)
    @traca_report[:upstreams].each(&block)
  end
end
