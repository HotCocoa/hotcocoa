# -*- coding: utf-8 -*-

##
# Application is a namespace for the classes that are used to specify
# and build application bundles.
module Application

  ##
  # An application specification, inspired by Gem::Specification that is
  # used by Rubygems.
  #
  # A specification object is used to build your [app bundle](http://developer.apple.com/library/mac/#documentation/CoreFoundation/Conceptual/CFBundles/Introduction/Introduction.html#//apple_ref/doc/uid/10000123i-CH1-SW1) and define the
  # [Info.plist](http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPRuntimeConfig/000-Introduction/introduction.html#//apple_ref/doc/uid/10000170-SW1)
  # metadata for the application.
  class Specification

    # @group App Metadata

    ##
    # Name of the app. Required.
    #
    # This name should be less than 16 characters long.
    #
    # @plist CFBundleName
    # @return [String]
    attr_accessor :name

    ##
    # The app's unique identifier, in reverse DNS form. Required.
    #
    # @example Identifier for Mail.app
    #   'com.apple.mail'
    #
    # @plist CFBundleIdentifier
    # @return [String]
    attr_accessor :identifier

    ##
    # The version of the app, usually including the build number.
    # Recommended.
    #
    # Defaults to `'1.0'`.
    #
    # @plist CFBundleVersion
    # @return [String]
    attr_accessor :version

    ##
    # The short version for the app. Optional.
    #
    # The short version for an app should be in the standard
    # `"$MAJOR.$MINOR.$PATCHLEVEL"` format.
    #
    # @plist CFBundleShortVersionString
    # @return [String]
    attr_accessor :short_version

    ##
    # The copyright string. Recommended.
    #
    # @example
    #   © 2011, Your Company
    #
    # @plist NSHumanReadableCopyright
    attr_accessor :copyright

    ##
    # Path to the icon file. Recommended.
    #
    # @plist CFBundleIconFile
    # @return [String]
    attr_accessor :icon

    ##
    # Four letter code identifying the bundle type. Required.
    #
    # The default value is 'APPL', which specifies that the bundle
    # is an application.
    #
    # @plist CFBundlePackageType
    # @return [String]
    attr_accessor :type

    ##
    # Four letter code that acts as a signature for the bundle. Optional.
    #
    # Defaults to '????', and most apps never set this value.
    #
    # @example TextEdit.app
    #   'ttxt'
    # @example Mail.app
    #   'emal'
    #
    # @plist CFBundleSignature
    # @return [String]
    attr_accessor :signature

    ##
    # Whether the app is an daemon with UI or a regular app. Optional.
    #
    # You can use this flag to hide the dock icon for the app.
    #
    # @return [Boolean]
    attr_accessor :agent

    # @todo CFBundleDocumentTypes
    # @return [Array<Hash>]
    # attr_accessor :doc_types

    ##
    # Any additional plist values that an application could have.
    #
    # Values here will override attributes set by other plist related
    # attributes.
    #
    # Empty by default.
    #
    # @return [Hash]
    attr_accessor :plist

    # @todo Support localization related plist keys natively
    # @todo CFBundleDevelopmentRegion (Recommended)

    # @group App Layout

    ##
    # List of resources that will be copied to the `Contents/Resources`
    # directory inside the app bundle.
    #
    # @return [Array<String>]
    attr_accessor :resources

    ##
    # List of source code files that will be copied to the app bundle.
    #
    # @return [Array<String>]
    attr_accessor :sources

    ##
    # Path to any Core Data `.xcdatamodel` directories that need to be
    # compiled and added to the app bundle.
    #
    # @return [Array<String>]
    attr_accessor :data_models

    # @group Deloyment Options

    ##
    # Whether to include the Ruby stdlib in the app when embedding MacRuby.
    #
    # @return [Boolean]
    attr_accessor :stdlib

    ##
    # Array of gem names to embed in the app bundle during deployment
    #
    # @return [Array<Gem::Requirement>]
    attr_accessor :gems

    ##
    # Declares a runtime dependency on a gem, with any given version
    # requirements. If the embedding is also set, then any dependent gems
    # will also be embedded into the app bundle.
    #
    # @example
    #   spec.add_runtime_dependency 'hotcocoa', '~> 0.6'
    def add_runtime_dependency gem, *requirements
      raise NotImplementedError, 'Please implement me :('
    end

    ##
    # Whether or not to embed BridgeSupport files when embedding the
    # MacRuby framework during deployment.
    #
    # Defaults to false. Useful if you need to deploy the app to
    # OS X 10.6.
    #
    # @return [Boolean]
    attr_accessor :embed_bs
    alias_method :embed_bs?, :embed_bs

    ##
    # Whether or not to always make a clean build of the app.
    #
    # Defaults to false.
    #
    # @return [Boolean]
    attr_accessor :overwrite
    alias_method :overwrite?, :overwrite

    ##
    # Any additional arguments to pass to `macruby_deploy` during
    # deployment.
    #
    # @return [Array<String>]
    attr_accessor :deploy_opts

    # @endgroup

    DEFAULT_ATTRIBUTES = {
      plist:       {},
      sources:     [],
      resources:   [],
      data_models: [],
      gems:        [],
      type:        'APPL',
      signature:   '????',
      version:     '1.0',
      stdlib:      true,
      agent:       false,
      overwrite:   false,
      embed_bs:    false
    }

    def initialize
      DEFAULT_ATTRIBUTES.each { |key, value| send "#{key}=", value }

      yield self if block_given?

      # go through plist and overwrite specific keys?

      verify!
    end

    def verify!
      verify_name
      verify_identifier
      verify_version
      verify_short_version
    end

    class Error < ArgumentError
    end

    def icon_exists?
      @icon ? File.exist?(@icon) : false
    end

    def self.load file
      eval File.read(file)
    end


    private

    def verify_name
      raise Error, 'a name is required for an appspec' unless @name
      @name = @name.to_s
      raise Error, 'an app name cannot be an empty string' if @name.empty?
      warn 'an app name should be less than 16 characters' if name.length >= 16
    end

    # @todo Should we try to make the regexp more strict?
    def verify_identifier
      raise Error, 'a bundle identifier is required for an appspec' unless @identifier
      @identifier = @identifier.to_s
      raise Error, 'a bundle identifier cannot be an empty string' if @identifier.empty?
      unless @identifier.match /^[A-Za-z0-9\.-]+$/
        raise Error, 'A bundle identifier may only use "-", ".", and alphanumeric characters.' +
          "You had #{@identifier.inspect}"
      end
    end

    def verify_version
      @version = @version.to_s
    end

    # @todo Should @version be enforced if @short_version is set?
    def verify_short_version
      return unless @short_version
      @short_version = @short_version.to_s
    end

  end
end
