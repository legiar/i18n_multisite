module I18nNamespace
  class KeyValue
    def self.include(base)
      raise "You can't include I18n::Backends::Fallbacks in this class." if base == ::I18n::Backend::Fallbacks
      super
    end

    def self.extend(base)
      raise "You can't extend this class with I18n::Backends::Fallbacks." if base == ::I18n::Backend::Fallbacks
      super
    end

    include ::I18n::Backend::KeyValue::Implementation
    include Fallbacks
    include Storing

  end
end
