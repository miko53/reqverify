# frozen_string_literal: true

# class String
# complement part
class String
  def underscore
    gsub(/::/, '/').gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                   .gsub(/([a-z\d])([A-Z])/, '\1_\2').tr('-', '_').downcase
  end

  def camelize
    split('_').collect(&:capitalize).join #=> "HelloWorld"
  end
end
