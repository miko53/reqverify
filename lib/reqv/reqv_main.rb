# frozen_string_literal: true

require 'optparse'
require 'reqv/project'
require 'reqv/traca_gen'
require 'reqv/export_csv'
require 'reqv/export_xlsx'
require 'reqv/log'
require 'reqv/display_status_req'

module Reqv
  # main application class ReqvMain
  class ReqvMain
    EXIT_FAILURE = 1

    def initialize
      @working_dir = ''
      @output_folder = ''
      @project = nil
    end

    def initialize_log_level(options)
      Log.verbose_level = Reqv::Log::LOG_LEVEL_NONE
      Log.verbose_level = Reqv::Log::LOG_LEVEL_INFO unless options[:verbose].nil?
      Log.verbose_level = Reqv::Log::LOG_LEVEL_DBG unless options[:debug].nil?
      Log.colorize_msg = false
      Log.colorize_msg = true unless options[:colorize].nil?
    end

    # load project according to +options+ hash
    def load_project_check_working_dir(options)
      @project = Project.new options[:project_file]
      @project.read
      if @project.loaded? # && Dir.exist?(@project.working_dir)
        @working_dir = @project.working_dir
        Log.info "project file: #{options[:project_file]}"
      else
        Log.error "project file is not valid or working dir doesn't exist"
        @project = nil
      end
      @project
    end

    # parse action argument
    # +options+ hash of option given in command line
    # +project+ Project class object
    def parse_and_launch_action(options)
      case options[:action]
      when 'export'
        check_export_output_arg(options)
        traca_report = generate_traceability(options)
        generate_export(options, traca_report) unless traca_report.nil?
      when 'status'
        traca_report = generate_traceability(options)
        display_status(traca_report) unless traca_report.nil?
      when 'list'
        doc_req = generate_doc_req(options)
        display_doc_req(doc_req) unless doc_req.nil?
      when 'clean'
        clean_intermediate_file
      else
        Log.error 'Unknown action'
      end
    end

    # check if output is given
    def check_export_output_arg(options)
      if options[:output_folder].nil?
        Log.error 'no output folder given, see help'
        exit EXIT_FAILURE
      else
        check_if_folder_exist_or_create_it(options[:output_folder])
        @output_folder = options[:output_folder]
      end

      check_output_file(options)
    end

    def check_output_file(options)
      if options[:export_format] == 'xlsx' && options[:output_file].nil?
        Log.error 'for xlsx, provide a output file , see help'
        exit EXIT_FAILURE
      else
        @output_file = options[:output_file]
      end
    end

    def check_if_folder_exist_or_create_it(folder_name)
      return if Dir.exist?(folder_name)

      begin
        Dir.mkdir(folder_name)
      rescue StandardError => e
        Log.error "unable to create folder #{folder_name}, #{e}"
        exit EXIT_FAILURE
      end
    end

    # launch effectif traceablity action
    def generate_traceability(options)
      traca_report = nil
      if !options[:relationship].nil?
        Log.info "Generate traceability #{options[:relationship]}"
        traca = TracaGenerator.new(@project)
        traca_report = traca.generate_traceability(options[:relationship], options[:plugins_path])
        Log.debug_pp traca_report unless traca_report.nil?
      else
        Log.error 'Error, no relationship given'
        exit EXIT_FAILURE
      end
      traca_report
    end

    def generate_export(options, traca_report)
      # pp r
      if traca_report.nil?
        Log.error 'Unable to create traceability data'
      else
        export = create_export(options[:export_format])
        export.export_traca_report report: traca_report, output_folder: @output_folder, output_file: @output_file
      end
    end

    def generate_doc_req(options)
      traca = TracaGenerator.new(@project)
      doc_req = traca.generate_doc_req_list(options[:doc], options[:plugins_path])
      Log.error "Document '#{options[:doc]}' doesn't exist" if doc_req.nil?

      doc_req
    end

    def clean_intermediate_file
      traca_ctrl = TracaGenerator.new(@project)
      traca_ctrl.clean
    end

    def create_export(format)
      export_gen = nil
      case format
      when 'xlsx'
        Log.info 'xlsx format'
        export_gen = ExportXlsx.new
      when 'csv'
        Log.info 'csv format'
        export_gen = ExportCsv.new
      else
        Log.error "unknown format #{format}"
        exit EXIT_FAILURE
      end
      export_gen
    end

    def display_status(traca_report)
      DisplayStatusReq.display(traca_report)
    end

    def display_doc_req(doc_req)
      doc_req.display
    end
  end
end
