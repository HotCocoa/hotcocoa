require 'test/application/helper'

class TestApplicationDocumentTypeSpecification < TestApplicationModule
  def rescue_spec_error_for
    begin
      yield
    rescue ArgumentError => e
      return e
    end
    flunk "no error thrown!"
  end
  
  def minimal_doc_type_spec
    DocumentTypeSpecification.new do |s|
      s.extensions = ["ext"]
      s.name       = "MyProjectDocument"
      s.role       = :editor
      yield s if block_given?
    end
  end
  
  def test_definition_of_a_valid_specification
    type = DocumentTypeSpecification.new do |doc_type|
      doc_type.extensions = ["ext"]
      doc_type.icon       = "MyIcon.icns"
      doc_type.name       = "MyProjectDocument"
      doc_type.role       = :editor
      doc_type.class      = "MyDocument"
    end
    assert_equal ["ext"],             type.info_plist_representation[:CFBundleTypeExtensions]
    assert_equal "MyIcon.icns",       type.info_plist_representation[:CFBundleTypeIconFile]
    assert_equal "MyProjectDocument", type.info_plist_representation[:CFBundleTypeName]
    assert_equal "Editor",            type.info_plist_representation[:CFBundleTypeRole]
    assert_equal "MyDocument",        type.info_plist_representation[:NSDocumentClass]
  end
  
  def test_extensions_are_an_array
    exception = rescue_spec_error_for do
      minimal_doc_type_spec {|s| s.extensions = 123}
    end
    assert_match /must be an array/, exception.message
  end
  
  def test_role_is_valid
    [:editor, :viewer, :none].each do |role|
      minimal_doc_type_spec {|s| s.role = role}
    end
    
    exception = rescue_spec_error_for do
      minimal_doc_type_spec {|s| s.role = "xxx"}
    end
    assert_match /not a valid role/, exception.message
  end
  
  def test_name_is_not_empty
    exception = rescue_spec_error_for do
      minimal_doc_type_spec {|s| s.name = ""}
    end
    assert_match /must not be empty/, exception.message
    
    exception = rescue_spec_error_for do
      minimal_doc_type_spec {|s| s.name = nil}
    end
    assert_match /must not be empty/, exception.message
  end
end
