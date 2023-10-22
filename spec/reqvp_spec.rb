# frozen_string_literal: true

require 'spec_helper'
require 'reqvp/reqvp_main'
require 'fileutils'

describe 'create a project' do # rubocop:disable Metrics/BlockLength
  before(:all) do
    @fixtures_path = 'spec/fixtures'
    @inputs_path = "#{@fixtures_path}/inputs/reqvp"
    @expected_path = "#{@fixtures_path}/expected/reqvp"
    @outputs_path = "#{@fixtures_path}/outputs"
  end

  describe 'create a empty project, with two docx imports' do
    before do
      argv = []
      argv.append 'create_project'
      argv.append 'example_project'
      argv.append "#{@outputs_path}/req_project_folder"
      argv.append 'req_project.reqprj'

      reqvp = Reqv::ReqvpMain.new
      reqvp.initialize_log_level
      @operation = reqvp.analyse_args(argv)
    end

    it 'create project file' do
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      expect(FileUtils.compare_file("#{@outputs_path}/req_project_folder/req_project.reqprj",
                                    "#{@expected_path}/01_create_project/req_project.reqprj")).to eq(true)
    end
  end

  describe 'add first doc' do
    before do
      argv = []
      argv.append 'add_doc'
      argv.append "#{@outputs_path}/req_project_folder/req_project.reqprj"
      argv.append 'import'
      argv.append 'SSS'
      argv.append 'handler'
      argv.append 'DocxImport'
      argv.append "#{@inputs_path}/SSS_sample.docx"

      reqvp = Reqv::ReqvpMain.new
      reqvp.initialize_log_level
      @operation = reqvp.analyse_args(argv)
    end

    it 'insert imported first doc' do
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec
      expect(FileUtils.compare_file("#{@outputs_path}/req_project_folder/req_project.reqprj",
                                    "#{@expected_path}/02_add_SSS/req_project.reqprj")).to eq(true)
    end
  end

  describe 'add second doc' do
    before do
      argv = []
      argv.append 'add_doc'
      argv.append "#{@outputs_path}/req_project_folder/req_project.reqprj"
      argv.append 'import'
      argv.append 'SRS'
      argv.append 'handler'
      argv.append 'DocxImport'
      argv.append "#{@inputs_path}/SRS_sample.docx"

      reqvp = Reqv::ReqvpMain.new
      reqvp.initialize_log_level
      @operation = reqvp.analyse_args(argv)
    end

    it 'insert imported second doc' do
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec
      expect(FileUtils.compare_file("#{@outputs_path}/req_project_folder/req_project.reqprj",
                                    "#{@expected_path}/03_add_SRS/req_project.reqprj")).to eq(true)
    end
  end

  describe 'add plugin rules for SRS' do # rubocop:disable Metrics/BlockLength
    before do
      @argv = []
      @argv.append 'add_plugin_rule'
      @argv.append "#{@outputs_path}/req_project_folder/req_project.reqprj"
      @argv.append 'SRS'
      @argv.append 'req_id_style_name'
      @argv.append 'REQ_ID'

      @reqvp = Reqv::ReqvpMain.new
      @reqvp.initialize_log_level
      @operation = @reqvp.analyse_args(@argv)
    end

    it 'insert rules for SRS ' do # rubocop:disable Metrics/BlockLength
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      @argv[3] = 'req_title_style_name'
      @argv[4] = 'REQ_TITLE'
      @operation = @reqvp.analyse_args(@argv)
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      @argv[3] = 'req_text_style_name'
      @argv[4] = 'REQ_TEXT'
      @operation = @reqvp.analyse_args(@argv)
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      @argv[3] = 'req_cov_style_name'
      @argv[4] = 'REQ_COV'
      @operation = @reqvp.analyse_args(@argv)
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      @argv[3] = 'req_attributes_style_name'
      @argv[4] = 'REQ_ATTRIBUTES'
      @operation = @reqvp.analyse_args(@argv)
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      expect(FileUtils.compare_file("#{@outputs_path}/req_project_folder/req_project.reqprj",
                                    "#{@expected_path}/04_add_plugin_rules_SRS/req_project.reqprj")).to eq(true)
    end
  end

  describe 'add plugin rules for SSS' do # rubocop:disable Metrics/BlockLength
    before do
      @argv = []
      @argv.append 'add_plugin_rule'
      @argv.append "#{@outputs_path}/req_project_folder/req_project.reqprj"
      @argv.append 'SSS'
      @argv.append 'req_id_style_name'
      @argv.append 'REQ_ID'

      @reqvp = Reqv::ReqvpMain.new
      @reqvp.initialize_log_level
      @operation = @reqvp.analyse_args(@argv)
    end

    it 'insert rules for SSS ' do # rubocop:disable Metrics/BlockLength
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      @argv[3] = 'req_title_style_name'
      @argv[4] = 'REQ_TITLE'
      @operation = @reqvp.analyse_args(@argv)
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      @argv[3] = 'req_text_style_name'
      @argv[4] = 'REQ_TEXT'
      @operation = @reqvp.analyse_args(@argv)
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      @argv[3] = 'req_cov_style_name'
      @argv[4] = 'REQ_COV'
      @operation = @reqvp.analyse_args(@argv)
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      @argv[3] = 'req_attributes_style_name'
      @argv[4] = 'REQ_ATTRIBUTES'
      @operation = @reqvp.analyse_args(@argv)
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      expect(FileUtils.compare_file("#{@outputs_path}/req_project_folder/req_project.reqprj",
                                    "#{@expected_path}/05_add_plugin_rules_SSS/req_project.reqprj")).to eq(true)
    end
  end

  describe 'add derived rule' do
    before do
      @argv = []
      @argv.append 'add_derived_name'
      @argv.append "#{@outputs_path}/req_project_folder/req_project.reqprj"
      @argv.append '[D|d]erived'

      @reqvp = Reqv::ReqvpMain.new
      @reqvp.initialize_log_level
      @operation = @reqvp.analyse_args(@argv)
    end

    it 'insert rules for derived ' do 
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      expect(FileUtils.compare_file("#{@outputs_path}/req_project_folder/req_project.reqprj",
                                    "#{@expected_path}/06_add_derived_rules/req_project.reqprj")).to eq(true)
    end
  end

  describe 'add relationship' do
    before do
      @argv = []
      @argv.append 'add_relationships'
      @argv.append "#{@outputs_path}/req_project_folder/req_project.reqprj"
      @argv.append 'SSS->SRS'
      @argv.append 'SRS'
      @argv.append 'covered-by'
      @argv.append 'SSS'

      @reqvp = Reqv::ReqvpMain.new
      @reqvp.initialize_log_level
      @operation = @reqvp.analyse_args(@argv)
    end

    it 'insert relationship rules' do
      expect(@operation).not_to eq(nil)
      expect(@operation.check_args).to eq(true)
      @operation.exec

      expect(FileUtils.compare_file("#{@outputs_path}/req_project_folder/req_project.reqprj",
                                    "#{@expected_path}/07_add_relationships/req_project.reqprj")).to eq(true)
    end
  end

  after(:all) do
    FileUtils.rm_rf("#{@outputs_path}/req_project_folder", secure: true)
  end
end
