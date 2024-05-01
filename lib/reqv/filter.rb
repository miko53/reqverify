# frozen_string_literal: true

# {req_attrs/planification}//S2//

module Reqv
  # class Filter
  class Filter
    def initialize(filter_exprs)
      @filter_exprs = filter_exprs.strip
      @attributes = []
      @regexp = nil
    end

    def compile
      r = Regexp.new("\{(.*?)\}\s*//(.*?)//")
      filt_param = r.match(@filter_exprs)

      return false if filt_param.nil? || filt_param.size < 3

      attribut = filt_param[1]
      exprs = filt_param[2]

      list_attr = attribut.split('/')

      rc = verify_attribut(list_attr)
      if exprs.nil?
        rc = false
      else
        @regexp = Regexp.new(exprs)
      end
      rc
    end

    def match(req)
      level = 0
      f = nil
      @attributes.each do |attr|
        f = if level.zero?
              req[attr]
            else
              f[attr]
            end
        break if f.nil?

        level += 1
      end

      if !f.nil?
        r = @regexp.match(f)
        r = if r.nil?
              false
            else
              true
            end
      else
        r = false
      end
      r
    end

    private

    def verify_attribut(list_attr)
      level = 0
      rc = true
      list_attr.each do |attr|
        rc = check_attr(attr, level)
        break if rc == false

        level += 1
      end

      return false if @attributes[0] == 'req_attrs' && @attributes[1].nil?

      rc
    end

    def check_attr(attr, level)
      case level
      when 0
        check_level0(attr)
      when 1
        check_level1(attr)
      else
        false
      end
    end

    def check_level0(attr)
      rc = true
      list_id = %w[req_id req_attrs req_title req_text]

      if list_id.include?(attr)
        @attributes[0] = attr
      else
        rc = false
      end
      rc
    end

    def check_level1(attr)
      rc = true
      # p attr
      # p @attributes[0]
      if @attributes[0] == 'req_attrs'
        @attributes[1] = attr
      else
        rc = false
      end
      rc
    end
  end
end
