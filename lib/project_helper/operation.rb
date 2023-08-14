# frozen_string_literal: true

require_relative '../project'

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
    puts("#{exe_name} create_project <project_name> <folder> <filename>\tcreate a new project in the given folder with the given filename")
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
    puts('create project')
  end
end
