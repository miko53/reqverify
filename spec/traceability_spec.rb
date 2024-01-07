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
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/01_basic_1.SSS_1.SRS/project.yaml"
      options[:action] = 'export'
      options[:export_format] = 'CsvExport'
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
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/02_basic_missing_req_1.SSS_1.SRS/project.yaml"
      options[:action] = 'export'
      options[:export_format] = 'CsvExport'
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
      @app = Reqv::ReqvMain.new
      @options = {}
      @options[:project_file] = "#{@inputs_path}/02_basic_missing_req_1.SSS_1.SRS/project.yaml"
      @options[:action] = 'status'
      # @options[:colorize] = 'y'
      @options[:relationship] = 'SSS<->SRS'
      @options[:output_folder] = "#{@outputs_path}/02_basic_missing_req_1.SSS_1.SRS"
      @app.initialize_log_level(@options)
      @app.load_project_check_working_dir(@options)
    end

    it 'displays traceability status and warn about missing requirement' do
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
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/01_basic_1.SSS_1.SRS/project.yaml"
      options[:action] = 'export'
      options[:export_format] = 'XlsxExport'
      options[:relationship] = 'SSS<->SRS'
      options[:output_file] = '03.xlsx'
      options[:verbose] = 'y'
      options[:output_folder] = "#{@outputs_path}/03_basic_1.SSS_1.SRS"
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates xlsx output trace 1 SSS -> 1 SRS' do
      expect(File.exist?("#{@outputs_path}/03_basic_1.SSS_1.SRS/03.xlsx")).to eq(true)
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/03_basic_1.SSS_1.SRS", secure: true)
    end
  end

  describe 'nominal 1 downstream, 2 upstream - output csv' do
    before do
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/04_nominal_2.SSS_1.SRS/project.yaml"
      options[:action] = 'export'
      options[:export_format] = 'CsvExport'
      options[:relationship] = 'SSS_all<->SRS'
      options[:verbose] = 'y'
      options[:output_folder] = "#{@outputs_path}/04_nominal_2.SSS_1.SRS"
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates csv and gives traceability 2 SSS -> 1 SRS' do
      expect(FileUtils.compare_file("#{@outputs_path}/04_nominal_2.SSS_1.SRS/traca_SRS.csv",
                                    "#{@expected_path}/04_nominal_2.SSS_1.SRS/traca_SRS.csv")).to eq(true)
      expect(FileUtils.compare_file("#{@outputs_path}/04_nominal_2.SSS_1.SRS/traca_SSS_1.csv",
                                    "#{@expected_path}/04_nominal_2.SSS_1.SRS/traca_SSS_1.csv")).to eq(true)
      expect(FileUtils.compare_file("#{@outputs_path}/04_nominal_2.SSS_1.SRS/traca_SSS_2.csv",
                                    "#{@expected_path}/04_nominal_2.SSS_1.SRS/traca_SSS_2.csv")).to eq(true)
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/04_nominal_2.SSS_1.SRS", secure: true)
    end
  end

  describe 'nominal 2 downstream, 1 upstream' do
    before do
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/05_nominal_1.SRS_2.STD/project.yaml"
      options[:action] = 'export'
      options[:export_format] = 'CsvExport'
      options[:relationship] = 'SRS<->STD_all'
      options[:verbose] = 'y'
      options[:output_folder] = "#{@outputs_path}/05_nominal_1.SRS_2.STD"
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates csv and gives traceability 1 SRS --> 2 STD' do
      expect(FileUtils.compare_file("#{@outputs_path}/05_nominal_1.SRS_2.STD/traca_SRS.csv",
                                    "#{@expected_path}/05_nominal_1.SRS_2.STD/traca_SRS.csv")).to eq(true)
      expect(FileUtils.compare_file("#{@outputs_path}/05_nominal_1.SRS_2.STD/traca_STD_1.csv",
                                    "#{@expected_path}/05_nominal_1.SRS_2.STD/traca_STD_1.csv")).to eq(true)
      expect(FileUtils.compare_file("#{@outputs_path}/05_nominal_1.SRS_2.STD/traca_STD_2.csv",
                                    "#{@expected_path}/05_nominal_1.SRS_2.STD/traca_STD_2.csv")).to eq(true)
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/05_nominal_1.SRS_2.STD", secure: true)
    end
  end

  describe 'not found requirement 1 - check status ouput' do # rubocop:disable Metrics/BlockLength
    before do
      @app = Reqv::ReqvMain.new
      @options = {}
      @options[:project_file] = "#{@inputs_path}/06_not_found_1.SSS_1.SRS/project.yaml"
      @options[:action] = 'status'
      # @options[:colorize] = 'y'
      @options[:relationship] = 'SSS<->SRS'
      @app.initialize_log_level(@options)
      @app.load_project_check_working_dir(@options)
    end

    it 'displays traceability status (1SSS->1SRS) and warn no existing requirements' do
      expected_stdio = <<~EXPECTED
        warning: 'SSS_REQ_010.1' doesn't exist !
        warning: 'SSS_RSQ_003.1' doesn't exist !
        document: SRS
          coverage: 80%
          number of requirement: 5
          number of uncovered requirement: 1
            SRS_REQ_001.1
          derived requirement: 40%
            SRS_REQ_003.1
            SRS_REQ_005.1
        document: SSS
          coverage: 75%
          number of requirement: 4
          number of uncovered requirement: 1
            SSS_REQ_003.1
      EXPECTED

      expect { @app.parse_and_launch_action(@options) }.to output(expected_stdio).to_stdout
    end
  end

  describe 'not found requirement 2 - check status ouput' do # rubocop:disable Metrics/BlockLength
    before do
      @app = Reqv::ReqvMain.new
      @options = {}
      @options[:project_file] = "#{@inputs_path}/07_not_found_1.SRS_2.STD/project.yaml"
      @options[:action] = 'status'
      # @options[:colorize] = 'y'
      @options[:relationship] = 'SRS<->STD_all'
      @app.initialize_log_level(@options)
      @app.load_project_check_working_dir(@options)
    end

    it 'displays traceability status (1 SRS -> 2 STD) and warn no existing requirements' do # rubocop:disable Metrics/BlockLength
      expected_stdio = <<~EXPECTED
        warning: 'SRS_REQ_010.1' doesn't exist !
        warning: 'SRS_REQ_020.1' doesn't exist !
        warning: 'SRS_REQ_101.1' doesn't exist !
        warning: 'SRT_REQ_002.1' doesn't exist !
        warning: 'SRS_REQ_03.1' doesn't exist !
        warning: 'SRS_REQ_02.1' doesn't exist !
        document: STD_1
          coverage: 40%
          number of requirement: 5
          number of uncovered requirement: 3
            STD_1_REQ_001.1
            STD_1_REQ_002.1
            STD_1_REQ_005.1
          derived requirement: 0%
        document: STD_2
          coverage: 100%
          number of requirement: 6
          number of uncovered requirement: 0
          derived requirement: 0%
        document: SRS
          coverage: 100%
          number of requirement: 6
          number of uncovered requirement: 0
      EXPECTED

      expect { @app.parse_and_launch_action(@options) }.to output(expected_stdio).to_stdout
    end
  end

  describe 'import xls test - check output yaml file' do
    before do
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/08_import_xls/project.yaml"
      options[:action] = 'status'
      options[:relationship] = 'SSS<->SRS'
      options[:verbose] = 'y'
      options[:output_folder] = "#{@outputs_path}/08_import_xls"
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates yaml file if xls imported with requirement rules' do
      expect(FileUtils.compare_file("#{@outputs_path}/08_import_xls/req_srs.yaml",
                                    "#{@expected_path}/08_import_xls/req_srs.yaml")).to eq(true)
      expect(FileUtils.compare_file("#{@outputs_path}/08_import_xls/req_sss.yaml",
                                    "#{@expected_path}/08_import_xls/req_sss.yaml")).to eq(true)
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/08_import_xls", secure: true)
    end
  end

  describe 'import docx test - check output yaml file' do # rubocop:disable Metrics/BlockLength
    before do
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/09_import_docx/project.yaml"
      options[:action] = 'status'
      options[:relationship] = 'SSS<->SRS'
      options[:verbose] = 'y'
      options[:output_folder] = "#{@outputs_path}/09_import_docx"
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates yaml file if docx imported with requirement rules' do
      expect(FileUtils.compare_file("#{@outputs_path}/09_import_docx/req_srs.yaml",
                                    "#{@expected_path}/09_import_docx/req_srs.yaml")).to eq(true)
    end

    it 'clean intermediate file' do
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/09_import_docx/project.yaml"
      options[:action] = 'clean'
      options[:relationship] = 'SSS<->SRS'
      options[:verbose] = 'y'
      options[:output_folder] = "#{@outputs_path}/09_import_docx"
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)

      expect(File.exist?("#{@outputs_path}/09_import_docx/req_srs.yaml")).to eq(false)
      expect(File.exist?("#{@inputs_path}/09_import_docx/req_sss.yaml")).to eq(true)
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/09_import_docx", secure: true)
    end
  end

  describe 'import custom plugin with docx - check output yaml file' do
    before do
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/10_import_custom_plugin/project.yaml"
      options[:action] = 'status'
      options[:relationship] = 'SSS<->SRS'
      options[:verbose] = 'y'
      options[:output_folder] = "#{@outputs_path}/10_import_custom_plugin"
      options[:plugins_path] = "#{@fixtures_path}/custom_plugins_dir"
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates yaml file of docx imported with a custom plugin' do
      expect(FileUtils.compare_file("#{@outputs_path}/10_import_custom_plugin/req_srs.yaml",
                                    "#{@expected_path}/10_import_custom_plugin/req_srs.yaml")).to eq(true)
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/10_import_custom_plugin", secure: true)
    end
  end

  describe 'import and list requirement of docx document' do # rubocop:disable Metrics/BlockLength
    before do
      @app = Reqv::ReqvMain.new
      @options = {}
      @options[:project_file] = "#{@inputs_path}/09_import_docx/project.yaml"
      @options[:action] = 'list'
      @options[:doc] = 'SRS'
      # @options[:colorize] = 'y'
      @app.initialize_log_level(@options)
      @app.load_project_check_working_dir(@options)
    end

    it 'displays list of requirement of a docx imported document' do
      expected_stdio = <<~EXPECTED
        Requirement list of SRS:
          SRS_001.1: SRS 001 Title
          SRS_002.1: SRS 002 Title
          SRS_003.1: SRS 003 Title
          SRS_004.1: SRS 004 Title
          SRS_005.1: SRS 005 Title
          SRS_006.1: SRS 006 Title
          SRS_007.1: SRS 007 Title
          SRS_008.1: SRS 008 Title
          SRS_009.1: SRS 009 Title
          SRS_010.1: SRS 010 Title
        Number of requirement: 10
      EXPECTED

      expect { @app.parse_and_launch_action(@options) }.to output(expected_stdio).to_stdout
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/09_import_docx", secure: true)
    end
  end

  describe 'import xls test - check compliance column' do
    before do
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/11_import_xls_allocated_matrix/project.yaml"
      options[:action] = 'status'
      options[:relationship] = 'SSS<->SRS'
      options[:verbose] = 'y'
      options[:output_folder] = "#{@outputs_path}/11_import_xls_allocated_matrix"
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates yaml file if xls imported with requirement rules' do
      expect(FileUtils.compare_file("#{@outputs_path}/11_import_xls_allocated_matrix/req_srs.yaml",
                                    "#{@expected_path}/11_import_xls_allocated_matrix/req_srs.yaml")).to eq(true)
      expect(FileUtils.compare_file("#{@outputs_path}/11_import_xls_allocated_matrix/req_sss.yaml",
                                    "#{@expected_path}/11_import_xls_allocated_matrix/req_sss.yaml")).to eq(true)
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/11_import_xls_allocated_matrix", secure: true)
    end
  end

  describe 'check requirement status indicates when requirement has not a unique ID' do
    before do
      @app = Reqv::ReqvMain.new
      @options = {}
      @options[:project_file] = "#{@inputs_path}/12_check_multiple_req_id/project.yaml"
      @options[:action] = 'list'
      @options[:doc] = 'SRS'
      @app.initialize_log_level(@options)
      @app.load_project_check_working_dir(@options)
    end

    it 'displays list of requirement of a docx imported document' do
      expected_stdio = <<~EXPECTED
        Requirement list of SRS:
          SRS_REQ_001.1: Requirement title
          SRS_REQ_002.1: Requirement title
          SRS_REQ_002.1: Requirement title
          SRS_REQ_003.1: Requirement title
          SRS_REQ_004.1: Requirement title
          SRS_REQ_005.1: Requirement title
          SRS_REQ_004.1: Requirement title
          SRS_REQ_010.1: Requirement title
          SRS_REQ_005.1: Requirement title
          SRS_REQ_010.1: Requirement title
          SRS_REQ_005.1: Requirement title
        Number of requirement: 11
        warning: SRS_REQ_002.1 is duplicated !
        warning: SRS_REQ_004.1 is duplicated !
        warning: SRS_REQ_005.1 is duplicated !
        warning: SRS_REQ_010.1 is duplicated !
      EXPECTED

      expect { @app.parse_and_launch_action(@options) }.to output(expected_stdio).to_stdout
    end
  end

  describe 'traca 1 SSS, 1 SRS, export custom csv format' do
    before do
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/01_basic_1.SSS_1.SRS/project.yaml"
      options[:action] = 'export'
      options[:export_format] = 'CsvExportMyRules'
      options[:relationship] = 'SSS<->SRS'
      options[:output_folder] = "#{@outputs_path}/13_basic_1.SSS_1.SRS"
      options[:plugins_path] = "#{@fixtures_path}/custom_plugins_dir"
      options[:verbose] = 'y'
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates traceability csv file' do
      expect(FileUtils.compare_file("#{@outputs_path}/13_basic_1.SSS_1.SRS/traca_SRS.csv",
                                    "#{@expected_path}/01_basic_1.SSS_1.SRS/traca_SRS.csv")).to eq(true)
      expect(FileUtils.compare_file("#{@outputs_path}/13_basic_1.SSS_1.SRS/traca_SSS.csv",
                                    "#{@expected_path}/01_basic_1.SSS_1.SRS/traca_SSS.csv")).to eq(true)
    end

    after do
      FileUtils.rm_rf("#{@outputs_path}/13_basic_1.SSS_1.SRS", secure: true)
    end
  end

  describe 'check derived list' do
    before do
      app = Reqv::ReqvMain.new
      options = {}
      options[:project_file] = "#{@inputs_path}/01_basic_1.SSS_1.SRS/project.yaml"
      options[:action] = 'export'
      options[:export_format] = 'CsvExport'
      options[:relationship] = 'SSS<->SRS'
      options[:output_folder] = "#{@outputs_path}/14_basic_1.SSS_1.SRS"
      options[:verbose] = 'y'
      app.initialize_log_level(options)
      app.load_project_check_working_dir(options)
      app.parse_and_launch_action(options)
    end

    it 'generates traceability csv file' do
      expect(FileUtils.compare_file("#{@outputs_path}/14_basic_1.SSS_1.SRS/traca_SRS.csv",
                                    "#{@expected_path}/14_basic_1.SSS_1.SRS/traca_SRS.csv")).to eq(true)
      expect(FileUtils.compare_file("#{@outputs_path}/14_basic_1.SSS_1.SRS/traca_SSS.csv",
                                    "#{@expected_path}/14_basic_1.SSS_1.SRS/traca_SSS.csv")).to eq(true)
      expect(FileUtils.compare_file("#{@outputs_path}/14_basic_1.SSS_1.SRS/traca_derived_report.csv",
                                    "#{@expected_path}/14_basic_1.SSS_1.SRS/traca_derived_report.csv")).to eq(true)
    end

  end
end
