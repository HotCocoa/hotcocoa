# -*- coding: utf-8 -*-

require 'rubygems'

##
# Application is a namespace for the classes that are used to specify
# and build application bundles.
module Application

  ##
  # Inspired by Gem::Specification that is used by Rubygems, this class
  # represents the configuration for a Mac OS X application bundle.
  #
  # A specification object is used to build your [app bundle](http://developer.apple.com/library/mac/#documentation/CoreFoundation/Conceptual/CFBundles/Introduction/Introduction.html#//apple_ref/doc/uid/10000123i-CH1-SW1) and define the
  # [Info.plist](http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPRuntimeConfig/000-Introduction/introduction.html#//apple_ref/doc/uid/10000170-SW1)
  # metadata for the application.
  class Specification

    ##
    # Read an app spec from file and return what is evaluated.
    #
    # @return [Application::Specification]
    def self.load file
      eval File.read(file)
    end

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
    # You can use this flag to hide the dock icon for the app; the
    # default value is false so that apps will have a dock icon by default.
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
    # attr_accessor :plist

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

    # @group Deployment Options

    ##
    # Whether to include the Ruby stdlib in the app when embedding
    # MacRuby. Set this to a Boolean to include/exclude the entire
    # standard library from being embedded.
    #
    # If you want to embed specific files from the standard library,
    # you can do so by setting this attribute a list of the names of
    # libraries you want.
    #
    # @example
    #
    #   # Nothing
    #   spec.stdlib = false
    #   # Everything
    #   spec.stdlib = true
    #   # Just 'base64', 'matrix', and 'set'
    #   spec.stdlib = ['base64', 'matrix', 'set']
    #
    # This attribute corresponds to the `--[no]-stdlib` and `--stdlib`
    # arguments for `macruby_deploy`.
    #
    # Defaults to true.
    #
    # @return [Boolean, Array<String>]
    attr_accessor :stdlib

    ##
    # @note If you choose to compile, the original source files will
    #       be removed.
    #
    # Whether or not to compile ruby source files when embedding.
    #
    # Defaults to `true`.
    #
    # @return [Boolean]
    attr_accessor :compile
    alias_method :compile?, :compile

    ##
    # @note HotCocoa will automatically be embedded during deployment
    #       and is not added to this list.
    #
    # Array of gem names to embed in the app bundle during deployment.
    #
    # @return [Array<Gem::Requirement>]
    attr_accessor :gems

    ##
    # Declares a runtime dependency on a gem, with any given version
    # requirements. If the embedding is also set, then any dependent gems
    # will also be embedded into the app bundle.
    #
    # This method was liberally borrowed from RubyGems project and has
    # the same semantics here as it does for a gem specification.
    #
    # @example
    #
    #   spec.add_runtime_dependency 'hotcocoa', '~> 0.6'
    #
    def add_runtime_dependency dependency, *requirements
      requirements = if requirements.empty? then
                       Gem::Requirement.default
                     else
                       requirements.flatten
                     end

      unless dependency.respond_to?(:name) &&
          dependency.respond_to?(:version_requirements)

        dependency = Gem::Dependency.new(dependency, requirements, :runtime)
      end

      gems << dependency
    end
    alias_method :add_dependency, :add_runtime_dependency

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
    # @todo Is this actually useful or can we get rid of it?
    #
    # Whether or not to always make a clean build of the app.
    #
    # Defaults to false.
    #
    # @return [Boolean]
    attr_accessor :overwrite
    alias_method :overwrite?, :overwrite

    # @endgroup

    DEFAULT_ATTRIBUTES = {
      # plist:       {}, # @todo Finish this before release
      sources:     [],
      resources:   [],
      data_models: [],
      gems:        [],
      type:        'APPL',
      signature:   '????',
      version:     '1.0',
      stdlib:      true,
      agent:       false,
      compile:     true,
      overwrite:   false,
      embed_bs:    false
    }

    def initialize
      DEFAULT_ATTRIBUTES.each { |key, value| send "#{key}=", value }

      unless block_given?
        msg = 'You must pass a block at initialization to setup the specification'
        raise Error, msg
      end
      yield self

      # @todo go through plist and overwrite specific keys?

      # @todo should we verify at initialization or defer until building?
      verify!
    end

    def verify!
      verify_name
      verify_identifier
      verify_version
      verify_short_version
      verify_copyright
      verify_type
      verify_signature
      verify_agent
    end

    class Error < ArgumentError
    end

    ##
    # Whether or not the icon exists for this spec.
    def icon_exists?
      @icon ? File.exist?(@icon) : false
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

    def verify_copyright
      @copyright = @copyright.to_s if @copyright
    end

    # @todo Should a warning be given if not embedding the stdlib?
    def verify_stdlib
      # need to be careful here; the main components of hotcocoa do
      # not depend on the stdlib right now, but if that changes then
      # this needs to be a failsafe
    end

    def verify_type
      @type = @type.to_s
      unless @type.length == 4
        raise Error, 'A bundle type must be exactly 4 characters'
      end
    end

    def verify_signature
      @signature = @signature.to_s
      unless @signature.length == 4
        raise Error, 'A bundle signature must be exactly 4 characters'
      end
    end

    def verify_agent
      # we need to force this to a boolean since it will be written
      # to the bundles Info.plist
      @agent = !!@agent
    end

  end
end
