# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

describe 'check traceability' do # rubocop:disable Metrics/BlockLength
  before(:all) do
    @fixtures_path = 'spec/fixtures'
    @inputs_path = "#{@fixtures_path}/inputs"
    @expected_path = "#{@fixtures_path}/expected"
    @outputs_path = "#{@fixtures_path}/outputs"
  end

  describe 'traca 1 SSS, 1 SRS, export csv format' do
    before do
      app = ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/01_basic_1.SSS_1.SRS/project.yaml"
      options[:action] = 'export'
      options[:export_format] = 'csv'
      options[:relationship] = 'SSS<->SRS'
      options[:output_folder] = "#{@outputs_path}/01_basic_1.SSS_1.SRS"
      options[:verbose] = 'y'
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates traceability csv file' do
      expect(FileUtils.compare_file("#{@outputs_path}/01_basic_1.SSS_1.SRS/traca_SRS.csv",
                                    "#{@expected_path}/01_basic_1.SSS_1.SRS/traca_SRS.csv")).to eq(true)
      expect(FileUtils.compare_file("#{@outputs_path}/01_basic_1.SSS_1.SRS/traca_SSS.csv",
                                    "#{@expected_path}/01_basic_1.SSS_1.SRS/traca_SSS.csv")).to eq(true)
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/01_basic_1.SSS_1.SRS", secure: true)
    end
  end

  describe 'basic test - missing requirement' do
    before do
      app = ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/02_basic_missing_req_1.SSS_1.SRS/project.yaml"
      options[:action] = 'export'
      options[:export_format] = 'csv'
      options[:relationship] = 'SSS<->SRS'
      options[:output_folder] = "#{@outputs_path}/02_basic_missing_req_1.SSS_1.SRS"
      options[:verbose] = 'y'
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates csv and warn about missing requirement' do
      expect(FileUtils.compare_file("#{@outputs_path}/02_basic_missing_req_1.SSS_1.SRS/traca_SRS.csv",
                                    "#{@expected_path}/02_basic_missing_req_1.SSS_1.SRS/traca_SRS.csv")).to eq(true)
      expect(FileUtils.compare_file("#{@outputs_path}/02_basic_missing_req_1.SSS_1.SRS/traca_SSS.csv",
                                    "#{@expected_path}/02_basic_missing_req_1.SSS_1.SRS/traca_SSS.csv")).to eq(true)
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/02_basic_missing_req_1.SSS_1.SRS", secure: true)
    end
  end

  describe 'basic test - missing requirement - display in console' do # rubocop:disable Metrics/BlockLength
    before do
      @app = ReqvMain.new
      @options = {}
      @options[:project_file] = "#{@inputs_path}/02_basic_missing_req_1.SSS_1.SRS/project.yaml"
      @options[:action] = 'status'
      # @options[:colorize] = 'y'
      @options[:relationship] = 'SSS<->SRS'
      @options[:output_folder] = "#{@outputs_path}/02_basic_missing_req_1.SSS_1.SRS"
      @app.initialize_log_level(@options)
      @app.load_project_check_working_dir(@options)
    end

    it 'displays status and warn about missing requirement' do
      expected_stdio = <<~EXPECTED
        document: SRS
          coverage: 60%
          number of requirement: 5
          number of uncovered requirement: 2
            SRS_REQ_001.1
            SRS_REQ_002.1
          derived requirement: 40%
            SRS_REQ_003.1
            SRS_REQ_005.1
        document: SSS
          coverage: 75%
          number of requirement: 4
          number of uncovered requirement: 1
            SSS_REQ_002.1
      EXPECTED

      expect { @app.parse_and_launch_action(@options) }.to output(expected_stdio).to_stdout
    end
  end

  describe 'basic test - output xlsx' do
    before do
      app = ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/01_basic_1.SSS_1.SRS/project.yaml"
      options[:action] = 'export'
      options[:export_format] = 'xlsx'
      options[:relationship] = 'SSS<->SRS'
      options[:output_file] = '03.xlsx'
      options[:verbose] = 'y'
      options[:output_folder] = "#{@outputs_path}/03_basic_1.SSS_1.SRS"
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates xlsx output' do
      expect(File.exist?("#{@outputs_path}/03_basic_1.SSS_1.SRS/03.xlsx")).to eq(true)
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/03_basic_1.SSS_1.SRS", secure: true)
    end
  end
end
