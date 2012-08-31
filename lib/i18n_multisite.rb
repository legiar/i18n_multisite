require "active_support/core_ext"
require "ext/i18n"
require "i18n_multisite/version"
require "i18n_multisite/fallbacks"

I18n::Backend::Simple.send :include, I18nMultisite::Fallbacks
