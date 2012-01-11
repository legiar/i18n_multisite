module I18nNamespace
  module I18n
    
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods 
      # TODO: fix this, its absolute
      ::I18n::RESERVED_KEYS << :namespaced
      
      def namespace
        config.namespace
      end

      def namespace=(ns)
        raise "Namespace contains unsupported objects. Allowed are: String, Symbol, Array[Symbol, String] or NilClass. Inspection: #{ns.inspect}" unless valid_namespace?(ns)
        config.namespace = ns
      end

      def store_resolved_translation(locale, key, value, options = {})
        raise "Key has to be a String" unless key.is_a? String
        raise "Value has to be a String or NilClass" if !value.is_a?(String) && !value.is_a?(NilClass)
        
        resolved = key.split('.').reverse.inject(value) {|a, n| {n => a}}

        backend.store_translations locale, resolved, options 
      end

      private
        # TODO: fix this complicated logic :)
        def valid_namespace?(ns)
          return true if [String, Symbol, NilClass].include?(ns.class)
          return false unless ns.is_a?(Array)

          # check array for invalid objects
          return false if ns.select(&:blank?).present?
          return false if ns.select{|o| ![String, Symbol].include?(o.class)}.present?

          return true
        end
    end
  end

  module Config
    attr_accessor :namespace
  end
end
