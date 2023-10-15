# frozen_string_literal: true

require 'spec_helper'
require 'optparse'
require 'byebug'

load 'bin/reqv'

describe 'check reqverify' do
  before(:all) do
    @fixtures_path = 'spec/fixtures'
    @inputs_path = "#{@fixtures_path}/inputs"
    @expected_path = "#{@fixtures_path}/expected"
    @outputs_path = "#{@fixtures_path}/outputs"
  end

  describe 'load_project_successfully' do
    before do
      app = Main.new
      options = {}
      options[:project_file] = "#{@inputs_path}/01_basic_1.SSS_1.SRS/project.yaml"
      options[:verbose] = 'y'
      app.initialize_log_level(options)
      @project = app.load_project_check_working_dir(options)
    end

    it 'project file exists' do
      expect(@project).to be_an_instance_of(Project)
    end
  end

  describe 'load_project_unsuccessfully' do
    before do
      app = Main.new
      options = {}
      options[:project_file] = "#{@inputs_path}/01_basic_1.SSS_1.SRS/no_project.yaml"
      options[:verbose] = 'y'
      app.initialize_log_level(options)
      @project = app.load_project_check_working_dir(options)
    end

    it 'project file must be nil' do
      expect(@project).to eq(nil)
    end
  end
end
