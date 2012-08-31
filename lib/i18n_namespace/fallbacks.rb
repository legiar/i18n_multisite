module I18nNamespace

  module Fallbacks
    include I18nNamespace::Helper

    def translate(locale, key, options = {})
      namespaced = options.fetch(:namespaced, false)

      return super if !namespaced || ::I18n.namespace.blank?
      default = extract_non_symbol_default!(options) if options[:default]

      scope     = to_a(options.delete(:scope))
      namespace = to_a(::I18n.namespace)

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
