module Spree
  module Frontend
    VERSION = '4.7.0'.freeze

    def gem_version
      Gem::Version.new(VERSION)
    end
  end
end
