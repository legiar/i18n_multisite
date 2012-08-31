require "i18n"

module I18n

  class Config
    attr_accessor :namespace
  end

  class << self

    def namespace
      config.namespace
    end

    def namespace=(value)
      raise "Namespace contains unsupported objects. Allowed are: String, Symbol, Array[Symbol, String] or NilClass. Inspection: #{ns.inspect}" unless valid_namespace?(value)
      config.namespace = value
    end

    private

      def valid_namespace?(value)
        case value
          when String, Symbol, NilClass
            true
          when Array
            return false if value.select(&:blank?).present?
            return false if value.select{|item| ![String, Symbol].include?(item.class)}.present?
            true
          else
            false
        end
      end
      
  end

end
