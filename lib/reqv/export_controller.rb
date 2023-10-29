# frozen_string_literal: true

require 'reqv/misc'
require 'reqv/log'

# module ExportPlugin
module ExportPlugin
  include Reqv
end

module Reqv
  DEFAULT_EXPORT_PATH = 'plugins/default_export'

  # class ExportController
  class ExportController
    def initialize(project)
      @project = project
    end

    def export(plugin_name:, plugins_path:, report:, output_folder:, output_file:)
      mod_path_list = build_plugins_path(plugin_name, plugins_path)

      r = load_export_class(mod_path_list)
      return if r == false

      launch_export(plugin_name, report, output_folder, output_file)
    end

    def build_plugins_path(class_name, custom_plugins_path)
      mod_path_try_list = []
      mod_file = "#{class_name.underscore}.rb"
      mod_path = File.join(File.dirname(__FILE__), DEFAULT_EXPORT_PATH)
      mod_path = File.join(mod_path, mod_file)
      mod_path_try_list.append(mod_path)

      mod_path_try_list.append(build_custom_plugins_path(mod_file, custom_plugins_path)) unless custom_plugins_path.nil?
      mod_path = File.join(Dir.getwd, mod_file)
      mod_path_try_list.append(mod_path)
      mod_path_try_list
    end

    def load_export_class(mod_path_list)
      r = false
      mod_path_list.each do |mod_path|
        begin
          r = load mod_path
          Log.info "loading #{mod_path} successfull" if r == true
        rescue LoadError
          Log.warning "loading #{mod_path} failed"
        end
        break if r == true
      end
      r
    end

    def launch_export(plugin_name, traca_report, output_folder, output_file)
      t = ExportPlugin.const_get(plugin_name).new
      status = t.export_traca_report(report: traca_report, output_folder: output_folder, output_file: output_file)
      if status == true
        Log.info "export successfull..."
      else
        Log.error "export failed..."
      end
    end
  end
end
