# frozen_string_literal: true

require 'yaml'

# class DocReq
class DocReq
  def initialize(project, doc_name, doc_path)
    @project = project
    @path = doc_path
    @doc_name = doc_name
    @doc_file = nil
    read
  end

  def loaded?
    !@doc_file.nil?
  end

  # return list of req_id of the document
  def req_id_list
    r = []
    @doc_file['reqs'].each do |req|
      r.append req['req_id']
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
      return true if req['req_id'] == req_id
    end
    false
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

  attr_accessor :doc_name

  private

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
      puts "Can not open file #{filename}, #{e}"
      e.backtrace.each do |l|
        p l
      end
      f = nil
    end
    f
  end

  def decode_yaml_file(f)
    @doc_file = YAML.safe_load f
  rescue StandardError => e
    @doc_file = nil
    puts "wrong file format, #{e}"
    e.backtrace.each do |l|
      p l
    end
  end
end
