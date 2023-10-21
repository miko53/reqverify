# frozen_string_literal: true

require 'reqvp/operation'

# main application class ReqvpMain
class ReqvpMain
  def analyse_args(argv) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity
    return nil if argv.empty?

    case argv[0].downcase
    when 'help'
      action = OperationHelp.new
    when 'create_project'
      action = OperationCreateProject.new(argv.drop(1))
    when 'add_doc'
      action = OperationAddDoc.new(argv.drop(1))
    when 'add_plugin_rule'
      action = OperationAddPluginRule.new(argv.drop(1))
    when 'add_relationships'
      action = OperationAddRelationships.new(argv.drop(1))
    when 'add_derived_name'
      action = OperationAddDerivedName.new(argv.drop(1))
    else
      return nil
    end
    action
  end

  def initialize_log_level
    Log.verbose_level = Log::LOG_LEVEL_INFO
    Log.colorize_msg = true
  end
end
