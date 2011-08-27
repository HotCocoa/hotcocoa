require 'hotcocoa/application/specification'
require 'hotcocoa/application/builder'

module HotCocoa
  class Application

  attr_accessor :spec, :builder

    def initialize spec
      @spec = case spec
      when ::Application::Specification
        spec
      when String
        ::Application::Specification.load spec
      end
      @builder = ::Application::Builder.new @spec
    end

    def build opts = {}
      builder.build opts
    end

    def deploy
      build deploy: true
    end

    def run
      `"./#{ builder.send :executable_file }"`
    end

    def clean
      builder.send :remove_bundle_root
    end

  end
end