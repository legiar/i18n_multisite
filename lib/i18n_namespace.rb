require "i18n"
require "i18n_namespace/version"
require "i18n_namespace/config"
require "i18n_namespace/helper"
require "i18n_namespace/storing"
require "i18n_namespace/fallbacks"
require "i18n_namespace/key_value"

I18n.send         :include, I18nNamespace::I18n
I18n::Config.send :include, I18nNamespace::Config
