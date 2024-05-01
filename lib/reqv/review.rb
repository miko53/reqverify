# frozen_string_literal: true

require 'reqv/log'

module Reqv
  # Review class display req with its coverage
  class Review
    def initialize(project, traca_report, relationship, filter)
      @project = project
      @traca_report = traca_report
      @relationship = relationship
      @upstream_docs = @project.upstream_docs(@relationship, filter)
      @downstream_docs = @project.downstream_docs(@relationship, filter)
    end

    def review_down_req
      @traca_report.each_downstream_doc do |doc|
        Log.display "review of #{doc.name}"
        doc.each_req_line do |traca_line|
          display_requirement_with_upstream_req(traca_line)
        end
      end
    end

    def review_up_req
      @traca_report.each_upstream_doc do |doc|
        Log.display "review of #{doc.name}"
        doc.each_req_line do |traca_line|
          display_requirement_with_downstream_req(traca_line)
        end
      end
    end

    private

    def display_requirement_with_upstream_req(traca_line)
      req_data = get_requirement_characteristics(@downstream_docs, traca_line.req_id)
      return if req_data.nil?

      # pp req_data
      Log.display('===========================================')
      display_requirement(req_data)

      coverage = traca_line.covers_req_list
      display_linked_requirement(@upstream_docs, coverage) unless coverage.empty?
      Log.display('===========================================')
    end

    def get_requirement_characteristics(doc_array, req_id)
      doc_array.each do |doc|
        req_data = doc.get_req_characteristics(req_id)
        return req_data unless req_data.nil?
      end
      nil
    end

    def display_requirement(req_data)
      Log.display("requirement: #{req_data['req_id']} - #{req_data['req_title']}")
      Log.display('  BEGIN')
      display_requirement_text(req_data['req_text'], 2)
      Log.display('  END')
    end

    def display_linked_requirement(doc_array, coverage)
      coverage.each do |req_id|
        req_data = get_requirement_characteristics(doc_array, req_id)
        Log.display("--> covers requirement: #{req_data['req_id']} - #{req_data['req_title']}")
        Log.display('    BEGIN')
        display_requirement_text(req_data['req_text'], 4)
        Log.display('    END')
      end
    end

    def display_requirement_text(req_text, nb_space)
      req_text_formatted = req_text.gsub('\\n', "\n")
      req_text_formatted.each_line do |line|
        text = space(nb_space) + line
        Log.display(text)
      end
    end

    def space(space_nb)
      ' ' * space_nb
    end

    def display_requirement_with_downstream_req(traca_line)
      req_data = get_requirement_characteristics(@upstream_docs, traca_line.req_id)
      return if req_data.nil?

      # pp req_data
      Log.display('===========================================')
      display_requirement(req_data)

      coverage = traca_line.covered_by_list
      display_linked_requirement(@downstream_docs, coverage) unless coverage.empty?
      Log.display('===========================================')
    end
  end
end
