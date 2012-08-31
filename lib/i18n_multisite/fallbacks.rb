module I18nMultisite

  module Fallbacks

    def translate(locale, key, options = {})
      return super if ::I18n.namespace.blank?
      default = extract_non_symbol_default!(options) if options[:default]

      scope     = Array.wrap(options.delete(:scope))
      namespace = Array.wrap(::I18n.namespace)

      (namespace.size + 1).times do |part|
        catch(:exception) do
          options[:scope] = (namespace | scope).reject(&:nil?)

          result = super(locale, key, options)
          result = super(locale, nil, options.merge(:default => default)) if result.nil? && default
          return result unless result.nil?
        end
        namespace.pop
      end

      return super(locale, nil, options.merge(:default => default)) if  default
      throw(:exception, ::I18n::MissingTranslation.new(locale, key, options))
    end

    def extract_non_symbol_default!(options)
      defaults = [options[:default]].flatten
      first_non_symbol_default = defaults.detect{|default| !default.is_a?(Symbol)}
      if first_non_symbol_default
        options[:default] = defaults[0, defaults.index(first_non_symbol_default)]
      end
      return first_non_symbol_default
    end

  end
end
