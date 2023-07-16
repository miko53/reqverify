# frozen_string_literal: true

require_relative 'string_compl'
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

  def check_and_import(doc_list)
    s = true
    doc_list.each do |doc_name|
      next unless @project.import?(doc_name)

      r = check_if_need_import?(doc_name)
      s = do_import(doc_name) if r == NEED_IMPORT && s == true
    end
    s
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
    puts 'check date'
    input_file_date = @project.input_file_date(doc_name)
    output_file_date = @project.output_file_date(doc_name)
    p input_file_date
    p output_file_date
    if input_file_date < output_file_date
      p 'done'
      IMPORT_DONE
    else
      p 'need import'
      NEED_IMPORT
    end
  end

  def do_import(doc_name)
    Log.info "import #{doc_name} ongoing..."

    handler_class = @project.get_handler(doc_name)
    handler_rules = @project.get_handler_options(doc_name)

    mod_file = "#{handler_class.underscore}.rb"
    mod_path = File.join(File.dirname(__FILE__), IMPORT_PATH)
    mod_path = File.join(mod_path, mod_file)

    p mod_path

    load mod_path, Import

    t = Import.const_get(handler_class).new
    t.rules = handler_rules
    status = t.import(@project.get_input_file(doc_name), @project.get_output_file(doc_name))
    Log.info "import #{doc_name} successfull..." if status
    Log.error "import #{doc_name} failed..." unless status
  end
end
