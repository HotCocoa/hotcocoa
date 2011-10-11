# -*- coding: utf-8 -*-

##
# Application is a namespace for the classes that are used to specify
# and build application bundles.
module Application

  ##
  # This class represents the configuration for a document type, used by document-based applications.
  # It is used to generate the Info.plist file
  #
  # See http://developer.apple.com/library/mac/#documentation/Carbon/Conceptual/LaunchServicesConcepts/LSCConcepts/LSCConcepts.html for details.
  #
  class DocumentTypeSpecification
    VALID_ROLES = {:editor => "Editor", :viewer => "Viewer", :none => "None"}

    attr_writer :extensions
    attr_writer :icon
    attr_writer :name
    attr_writer :role
    attr_writer :class

    def initialize
      unless block_given?
        msg = 'You must pass a block at initialization to declare the new document type'
        raise ArgumentError, msg
      end
      yield self
      
      verify!
    end
    
    # @todo CFBundleTypeMIMETypes
    # @todo LSTypeIsPackage
    # @todo CFBundleTypeOSTypes
    def info_plist_representation
      {
        CFBundleTypeExtensions: @extensions,
        CFBundleTypeIconFile:   @icon,
        CFBundleTypeName:       @name,
        CFBundleTypeRole:       VALID_ROLES[@role], 
        NSDocumentClass:        @class
      }
    end
    
    protected
    def verify!
      verify_name
      verify_extensions
      verify_role
    end
    
    def verify_name
      raise ArgumentError, "doc type name must not be empty" if @name.nil? or @name.empty?
    end
    
    def verify_extensions
      raise ArgumentError, "doc type extensions must be an array" unless @extensions.is_a?(Array)
    end
    
    def verify_role
      raise ArgumentError, "#{@role} is not a valid role. A doc type role must be one of [:editor, :viewer, :none]" unless VALID_ROLES.keys.include?(@role)
    end
  end
end
