# frozen_string_literal: true

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

  def check_args; end

  def exec; end
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
    Log.info('create project')
  end
end

# AddDoc operation
class OperationAddDoc < Operation
  def check_args
    return false if @arg.size < 4

    return false if (@arg[1] != 'raw') && (@arg[1] != 'import')

    true
  end

  def exec
    project = Project.new @arg[0]
    project.read
    if project.loaded?
      @working_dir = project.working_dir
      Log.info "project: '#{project.project_name}' loaded"
    else
      Log.error "project file is not valid or working dir doesn't exist"
    end

    return unless @arg[1] == 'raw'

    docname = @arg[2]
    filename = @arg[3]
    project.insert_doc(docname, filename)
    project.write
    Log.info('doc inserted')
  end
end
