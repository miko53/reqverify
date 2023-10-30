# frozen_string_literal: true

# common part
module Reqv
  def self.exe_name
    File.basename($PROGRAM_NAME)
  end

  def self.build_custom_plugins_path(mod_file, path)
    if File.absolute_path?(path) == false
      mod_path = File.join(Dir.getwd, path)
      mod_path = File.join(mod_path, mod_file)
    else
      mod_path = File.join(path, mod_file)
    end
    mod_path
  end
end
