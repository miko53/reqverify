# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

describe 'check robustness' do
  before(:all) do
    @fixtures_path = 'spec/fixtures'
    @inputs_path = "#{@fixtures_path}/inputs"
    @expected_path = "#{@fixtures_path}/expected"
    @outputs_path = "#{@fixtures_path}/outputs"
  end

  describe 'check invalid project' do
    before do
      @app = Reqv::ReqvMain.new
      @options = {}
      @options[:project_file] = "#{@inputs_path}/02_basic_missing_req_1.SSS_1.SRS/req_srs.yaml"
      @options[:action] = 'status'
      # @options[:colorize] = 'y'
      @options[:relationship] = 'SSS<->SRS'
      @options[:output_folder] = "#{@outputs_path}/02_basic_missing_req_1.SSS_1.SRS"
      @app.initialize_log_level(@options)
    end

    it 'project not loader' do
      project = @app.load_project_check_working_dir(@options)
      expect(project).to eq(nil)
    end
  end
end
