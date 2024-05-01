# frozen_string_literal: true

require 'yaml'
require 'reqv/log'

module Reqv
  # class DocReq
  class DocReq
    def initialize(project, doc_name, doc_path, filter = nil)
      @project = project
      @path = doc_path
      @doc_name = doc_name
      @doc_file = nil
      @filter = filter
      read
    end

    def loaded?
      !@doc_file.nil?
    end

    # return list of req_id of the document
    def req_id_list
      r = []
      @doc_file['reqs'].each do |req|
        r.append req['req_id'] if selected?(req)
      end
      r
    end

    def cov_reqs_list(req_id)
      r = []
      @doc_file['reqs'].each do |req|
        r = req['req_cov'] if req['req_id'] == req_id
      end
      r
    end

    def req_id_exist?(req_id)
      @doc_file['reqs'].each do |req|
        return true if req['req_id'] == req_id && selected?(req)
      end
      false
    end

    def get_req_characteristics(req_id)
      @doc_file['reqs'].each do |req|
        return req if req['req_id'] == req_id
      end
      nil
    end

    def req_list_of_covered_id(cov_id)
      r = []
      @doc_file['reqs'].each do |req|
        req_cov_list = req['req_cov']
        req_cov_list&.each do |req_cov|
          if cov_id == req_cov
            r.append req['req_id']
            # break
          end
        end
      end
      # puts "r = #{r}"
      # r.uniq!
      r
    end

    def display
      Log.display("Requirement list of #{@doc_name}:")
      nb_req = 0
      @doc_file['reqs'].each do |req|
        if selected?(req)
          Log.display("  #{req['req_id']}: #{req['req_title']}")
          nb_req += 1
        end
      end
      Log.display("Number of requirement: #{nb_req}")
      duplicated.each do |req_id|
        Log.warning("#{req_id} is duplicated !")
      end
    end

    attr_accessor :doc_name

    private

    def selected?(req)
      if @filter.nil? || @filter.match(req)
        true
      else
        false
      end
    end

    def duplicated
      temp = {}
      duplicate = []
      @doc_file['reqs'].each do |req|
        # set map item to 1 if not exist, otherwise add one to it
        temp[req['req_id']] = (temp[req['req_id']] || 0) + 1
        duplicate.append req['req_id'] if temp[req['req_id']] > 1
      end
      duplicate.uniq
    end

    def read
      f = read_file
      return if f.nil?

      decode_yaml_file f
      f.close
    end

    def read_file
      begin
        filename = File.join(@project.working_dir, @path)
        f = File.open(filename, 'r')
      rescue StandardError => e
        Log.error "Can not open file #{filename}, #{e}"
        # e.backtrace.each do |l|
        #  p l
        # end
        f = nil
      end
      f
    end

    def decode_yaml_file(file)
      @doc_file = YAML.safe_load file
    rescue StandardError => e
      @doc_file = nil
      Log.error "wrong file format, #{e}"
      # e.backtrace.each do |l|
      #  p l
      # end
    end
  end
end
