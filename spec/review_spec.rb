# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

describe 'check review' do # rubocop:disable Metrics/BlockLength
  before(:all) do
    @fixtures_path = 'spec/fixtures'
    @inputs_path = "#{@fixtures_path}/inputs"
    @expected_path = "#{@fixtures_path}/expected"
    @outputs_path = "#{@fixtures_path}/outputs"
  end

  describe 'review traceablity from downstream to upstream display on console' do # rubocop:disable Metrics/BlockLength
    before do
        @app = Reqv::ReqvMain.new
        @options = {}
        @options[:project_file] = "#{@inputs_path}/04_nominal_2.SSS_1.SRS/project.yaml"
        @options[:action] = 'review_down'
        # @options[:colorize] = 'y'
        @options[:relationship] = 'SSS_all<->SRS'
        @options[:output_folder] = "#{@outputs_path}/04_nominal_2.SSS_1.SRS"
        @app.initialize_log_level(@options)
        @app.load_project_check_working_dir(@options)
      end

    it 'displays requirement data with its upstream traceability' do # rubocop:disable Metrics/BlockLength
      expected_stdio = <<~EXPECTED
        review of SRS
        ===========================================
        requirement: SRS_REQ_001.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SSS_1_REQ_002.1 - Requirement title
            BEGIN
            text req
            END
        --> covers requirement: SSS_2_REQ_003.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SRS_REQ_002.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SSS_1_REQ_002.1 - Requirement title
            BEGIN
            text req
            END
        --> covers requirement: SSS_2_REQ_004.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SRS_REQ_003.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SSS_1_REQ_003.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        --> covers requirement: SSS_2_REQ_005.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SRS_REQ_004.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SSS_1_REQ_004.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        --> covers requirement: SSS_2_REQ_006.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SRS_REQ_005.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SSS_1_REQ_005.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        --> covers requirement: SSS_2_REQ_001.1 - Requirement title
            BEGIN
            text req
            END
        ===========================================
        ===========================================
        requirement: SRS_REQ_006.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SSS_1_REQ_001.1 - Requirement title
            BEGIN
            text req
            END
        --> covers requirement: SSS_2_REQ_002.1 - Requirement title
            BEGIN
            text req
            END
        ===========================================
      EXPECTED

      expect { @app.parse_and_launch_action(@options) }.to output(expected_stdio).to_stdout
    end
  end

  describe 'review traceablity from upstream to upstream display on console' do # rubocop:disable Metrics/BlockLength
    before do
        @app = Reqv::ReqvMain.new
        @options = {}
        @options[:project_file] = "#{@inputs_path}/04_nominal_2.SSS_1.SRS/project.yaml"
        @options[:action] = 'review_up'
        # @options[:colorize] = 'y'
        @options[:relationship] = 'SSS_all<->SRS'
        @options[:output_folder] = "#{@outputs_path}/04_nominal_2.SSS_1.SRS"
        @app.initialize_log_level(@options)
        @app.load_project_check_working_dir(@options)
      end

    it 'displays requirement data with its upstream traceability' do # rubocop:disable Metrics/BlockLength
      expected_stdio = <<~EXPECTED
        review of SSS_1
        ===========================================
        requirement: SSS_1_REQ_001.1 - Requirement title
          BEGIN
          text req
          END
        --> covers requirement: SRS_REQ_006.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SSS_1_REQ_002.1 - Requirement title
          BEGIN
          text req
          END
        --> covers requirement: SRS_REQ_001.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        --> covers requirement: SRS_REQ_002.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SSS_1_REQ_003.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SRS_REQ_003.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SSS_1_REQ_004.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SRS_REQ_004.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SSS_1_REQ_005.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SRS_REQ_005.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        review of SSS_2
        ===========================================
        requirement: SSS_2_REQ_001.1 - Requirement title
          BEGIN
          text req
          END
        --> covers requirement: SRS_REQ_005.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SSS_2_REQ_002.1 - Requirement title
          BEGIN
          text req
          END
        --> covers requirement: SRS_REQ_006.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SSS_2_REQ_003.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SRS_REQ_001.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SSS_2_REQ_004.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SRS_REQ_002.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SSS_2_REQ_005.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SRS_REQ_003.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
        ===========================================
        requirement: SSS_2_REQ_006.1 - Requirement title
          BEGIN
          this req ... isdf sdfsdfklskdfmsdf sdfsdmf
          sdf sdfk sdf sdf sdfm dfk sdm f
          sdfkfms
          END
        --> covers requirement: SRS_REQ_004.1 - Requirement title
            BEGIN
            this req ... isdf sdfsdfklskdfmsdf sdfsdmf
            sdf sdfk sdf sdf sdfm dfk sdm f
            sdfkfms
            END
        ===========================================
      EXPECTED

      expect { @app.parse_and_launch_action(@options) }.to output(expected_stdio).to_stdout
    end
  end
end
