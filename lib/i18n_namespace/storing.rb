module I18nNamespace
  module Storing
    include I18nNamespace::Helper

    def store_translations(locale, data, options = {})
      # TODO: use delete instead of fetch
      namespaced = options.fetch(:namespaced, false)
    
      if namespaced && ::I18n.namespace.present?
        data = to_a(::I18n.namespace).reverse.inject(data) {|a, n| {n => a}}
      end

      super locale, data, options
    end
  end
end
