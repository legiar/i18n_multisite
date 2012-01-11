module I18nNamespace

  module Fallbacks
    include I18nNamespace::Helper

    def translate(locale, key, options = {})
      namespaced = options.fetch(:namespaced, false)

      return super if !namespaced || ::I18n.namespace.blank?
      # TODO: accept default, look for i18n/backend/fallback for a solution
      # default = extract_string_or_lambda_default!(options) if options[:default]
      
      scope     = to_a(options.delete(:scope))
      namespace = to_a(::I18n.namespace)
       
      (namespace.size + 1).times do |part|
        catch(:exception) do
          options[:scope] = (namespace | scope).reject(&:nil?)

          result = super(locale, key, options)
          return result unless result.nil?
        end
        namespace.pop
      end

      # return super(locale, nil, options.merge(:default => default)) if default
      throw(:exception, ::I18n::MissingTranslation.new(locale, key, options))
    end
    
  end
end
