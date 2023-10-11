# frozen_string_literal: true

require_relative 'misc'
require_relative 'log'

# module Import
module Import
end

# class ImportController
class ImportController
  ERR_INPUT_FILE_DOESNT_EXIST = 1
  NEED_IMPORT = 2
  IMPORT_DONE = 3

  IMPORT_PATH = 'import_plugins'

  def initialize(project)
    @project = project
  end

  def check_and_import(doc_list, custom_plugins_path)
    doc_list.each do |doc_name|
      next unless @project.import?(doc_name)

      r = check_if_need_import?(doc_name)
      prepare_and_launch_import(doc_name, custom_plugins_path) if r == NEED_IMPORT
    end
  end

  def check_if_need_import?(doc_name)
    input_file_exist = @project.input_file_exist?(doc_name)
    output_file_exist = @project.output_file_exist?(doc_name)

    if input_file_exist && output_file_exist
      r = check_if_need_do_import_again?(doc_name)
    elsif input_file_exist && !output_file_exist
      r = NEED_IMPORT
    elsif !input_file_exist
      Log.error("File not found for doc: #{doc_name}")
      r = ERR_INPUT_FILE_DOESNT_EXIST
    end
    r
  end

  def check_if_need_do_import_again?(doc_name)
    input_file_date = @project.input_file_date(doc_name)
    output_file_date = @project.output_file_date(doc_name)
    if input_file_date < output_file_date
      IMPORT_DONE
    else
      Log.info "doc #{doc_name} modified, do import again"
      NEED_IMPORT
    end
  end

  def prepare_and_launch_import(doc_name, custom_plugins_path)
    Log.info "import #{doc_name} ongoing..."
    handler_class = @project.get_handler(doc_name)
    mod_path_list = build_plugins_path(handler_class, custom_plugins_path)

    r = load_import_class(mod_path_list)
    return if r == false

    launch_import(handler_class, doc_name)
  end

  def launch_import(handler_class, doc_name)
    t = Import.const_get(handler_class).new
    t.rules = @project.get_handler_options(doc_name)
    status = t.import(@project.get_input_file(doc_name), @project.get_output_file(doc_name))
    if status == true
      Log.info "import #{doc_name} successfull..."
    else
      Log.error "import #{doc_name} failed..."
    end
  end

  def build_plugins_path(class_name, custom_plugins_path)
    mod_path_try_list = []
    mod_file = "#{class_name.underscore}.rb"
    mod_path = File.join(File.dirname(__FILE__), IMPORT_PATH)
    mod_path = File.join(mod_path, mod_file)
    mod_path_try_list.append(mod_path)

    mod_path_try_list.append(build_custom_plugins_path(mod_file, custom_plugins_path)) unless custom_plugins_path.nil?
    mod_path = File.join(Dir.getwd, mod_file)
    mod_path_try_list.append(mod_path)
    mod_path_try_list
  end

  def build_custom_plugins_path(mod_file, path)
    if File.absolute_path?(path) == false
      mod_path = File.join(Dir.getwd, path)
      mod_path = File.join(mod_path, mod_file)
    else
      mod_path = File.join(path, mod_file)
    end
    mod_path
  end

  def load_import_class(mod_path_list)
    r = false
    mod_path_list.each do |mod_path|
      begin
        r = load mod_path, Import
        Log.info "loading #{mod_path} successfull" if r == true
      rescue LoadError
        Log.warning "loading #{mod_path} failed"
      end
      break if r == true
    end
    r
  end

  def clean
    doc_list = @project.doc_list
    doc_list.each do |doc|
      doc_path = @project.get_output_file(doc)
      begin
        File.delete(doc_path)
      rescue StandardError
        # do nothing
      end
      Log.info "#{doc_path} removed"
    end
  end
end
