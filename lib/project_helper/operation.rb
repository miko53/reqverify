# frozen_string_literal: true

require_relative '../string_compl'
require_relative '../project'
require_relative '../log'

def exe_name
  File.basename($PROGRAM_NAME)
end

# Operation
class Operation
  def initialize(arg = nil)
    @arg = arg
  end

  def load_project(filename)
    @project = Project.new filename
    @project.read
    if @project.loaded?
      @working_dir = @project.working_dir
      Log.info "project: '#{@project.project_name}' loaded"
      true
    else
      Log.error "project file is not valid or working dir doesn't exist"
      false
    end
  end

  def check_args
    raise NoMethodError
  end

  def exec
    raise NoMethodError
  end
end

# OperationHelp
class OperationHelp < Operation
  def check_args
    true
  end

  def exec
    print_help
  end

  def print_help
    puts("#{exe_name} commands:")
    puts("#{exe_name} create_project <project_name> <folder> <filename>\tcreate a new project in the given folder" \
        ' with the given filename')
    puts("#{exe_name} add_doc <project_file> raw <doc_name> <doc_filename>")
    puts("#{exe_name} add_doc <project_file> import <doc_name> handler <import_plugin> <doc_filename>" \
       ' <doc_yaml_file,optional>')
    puts("#{exe_name} add_plugin_rule <project_file> <doc_name> <rule_name> <rule_value> <rule_type, optional>")
    puts("#{exe_name} add_relationships <project_file> <relation name> <doc_list> covered-by <doc_list>")
    puts("#{exe_name} add_derived_name <project_file> <derived_reqexp")
  end
end

# CreateProject operation
class OperationCreateProject < Operation
  def check_args
    (@arg.size >= 3)
  end

  def exec
    project_name = @arg[0]
    dirname = @arg[1]
    filename = File.join(dirname, @arg[2])
    Dir.mkdir dirname unless Dir.exist? dirname
    d = Project.new filename
    d.build
    d.project_name = project_name
    d.write
    Log.info("create project '#{project_name}'")
  end
end

# AddDoc operation
class OperationAddDoc < Operation
  def check_args
    return false if @arg.size < 4

    return false if (@arg[1] != 'raw') && (@arg[1] != 'import')

    return false if @arg[1] == 'import' && (@arg.size < 6 || @arg[3] != 'handler')

    true
  end

  def exec
    return if load_project(@arg[0]) == false

    select_and_execute
  end

  private

  def select_and_execute
    case @arg[1]
    when 'raw'
      exec_raw
    when 'import'
      exec_import
    end
  end

  def exec_raw
    docname = @arg[2]
    filename = @arg[3]
    b = @project.insert_doc_raw(docname, filename)
    if b
      @project.write
      Log.info("doc: '#{docname}' inserted")
    else
      Log.warning('not inserted - already exists')
    end
  end

  def exec_import
    docname = @arg[2]
    pluginname = @arg[4]
    filename = @arg[5]
    filename_yaml = @arg[6]
    b = @project.insert_doc_with_plugin(docname, pluginname, filename, filename_yaml)
    if b
      @project.write
      Log.info("doc: '#{docname}' inserted")
    else
      Log.warning('not inserted')
    end
  end
end

# class OperationAddPluginRule
class OperationAddPluginRule < Operation
  def check_args
    (@arg.size >= 4)
  end

  def exec
    return if load_project(@arg[0]) == false

    docname = @arg[1]
    rulename = @arg[2]
    rulevalue = @arg[3]
    ruletype = @arg[4]

    b = @project.insert_plugin_rule(docname, rulename, rulevalue, ruletype)
    if b
      @project.write
      Log.info("rule: '#{rulename} for '#{docname}' inserted")
    else
      Log.warning('not inserted')
    end
  end
end

# class OperationAddRelationships
class OperationAddRelationships < Operation
  def check_args
    return false if @arg.size < 5

    array_list_docs = @arg.split('covered-by')
    return false if array_list_docs[0].nil? || array_list_docs[0].size < 3

    return false if array_list_docs[1].nil? || array_list_docs[1].size < 2

    @project_file = array_list_docs[0].first
    @relationship_name = array_list_docs[0].at(1)
    @up_docs = array_list_docs[0].drop(2)
    @down_docs = array_list_docs[1].drop(1)

    true
  end

  def exec
    return if load_project(@project_file) == false

    b = @project.insert_relationships(@relationship_name, @up_docs, @down_docs)
    if b
      @project.write
      Log.info("relationships #{@up_docs} --> #{@down_docs} added")
    else
      Log.warning('relationships not inserted')
    end
  end
end

# class OperationAddDerivedName
class OperationAddDerivedName < Operation
  def check_args
    return false if @arg.size < 2

    true
  end

  def exec
    return if load_project(@arg[0]) == false

    b = @project.insert_derived_name(@arg[1])
    if b
      @project.write
      Log.info('inserted')
    else
      Log.warning('not inserted')
    end
  end
end
