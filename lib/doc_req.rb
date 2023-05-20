# frozen_string_literal: true

require 'yaml'

# class DocReq
class DocReq
  def initialize(docname, docpath)
    @path = docpath
    @docname = docname
    @doc = nil
    read
  end

  def loaded?
    !@doc.nil?
  end

  # return list of req_id of the document
  def req_id_list
    r = []
    @doc['reqs'].each do |req|
      r.append req['req_id']
    end
    r
  end

  def cov_reqs_list(req_id)
    r = []
    @doc['reqs'].each do |req|
      r = req['req_cov'] if req['req_id'] == req_id
    end
    r
  end

  def req_id_exist?(req_id)
    @doc['reqs'].each do |req|
      return true if req['req_id'] == req_id
    end
    false
  end

  def req_list_of_covered_id(cov_id)
    r = []
    @doc['reqs'].each do |req|
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

  attr_accessor :docname

  private

  def read
    begin
      f = File.open(@path, 'r')
    rescue StandardError => e
      puts "Can not open file #{@path}, #{e}"
      f = nil
    end
    return if f.nil?

    begin
      @doc = YAML.safe_load f
    rescue StandardError => e
      @doc = nil
      puts "wrong file format, #{e}"
    end
  end
end
