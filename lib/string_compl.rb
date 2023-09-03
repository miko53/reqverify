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

  def integer?
    [                          # In descending order of likeliness:
      /^[-+]?[1-9]([0-9]*)?$/, # decimal
      /^0[0-7]+$/,             # octal
      /^0x[0-9A-Fa-f]+$/,      # hexadecimal
      /^0b[01]+$/              # binary
    ].each do |match_pattern|
      return true if self =~ match_pattern
    end
    false
  end
end

# class Array
# complement part
class Array
  def split(entry)
    r = []
    b = 0
    r[0] = []
    r[1] = []
    each do |i|
      b = 1 if i == entry
      if b.zero?
        r[0] << i
      else
        r[1] << i
      end
    end
    r
  end
end
