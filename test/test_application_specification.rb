require 'hotcocoa/application/specification'
require 'stringio'

class TestApplicationSpecification < MiniTest::Unit::TestCase
  include Application

  TEST_DIR = File.join(ENV['TMPDIR'], 'test_app_specification')

  # Some HotCocoa appspec files, converted from build.yml files borrowed from projects on Github
  HOTCONSOLE = 'test/fixtures/hotconsole.appspec'
  CALCULATOR = 'test/fixtures/calculator.appspec'
  STOPWATCH  = 'test/fixtures/stopwatch.appspec'
  EMPTY_APP  = 'test/fixtures/empty.appspec'

  def setup;    FileUtils.mkdir TEST_DIR; end
  def teardown; FileUtils.rm_rf TEST_DIR; end

  def rescue_spec_error_for &block
    begin
      Specification.new &block
    rescue Specification::Error => e
      return e
    end
  end

  def test_reads_attributes
    spec = Specification.load HOTCONSOLE
    assert_equal 'HotConsole',                spec.name
    assert_equal '1.0',                       spec.version
    assert_equal 'resources/HotConsole.icns', spec.icon

    spec = Specification.load CALCULATOR
    assert_equal 'Calculator', spec.name
    assert_equal '2.0', spec.version
  end

  def test_name_is_string_of_given_name
    ['Test', [1,2,3]].each do |name|
      spec = Specification.new do |s|
        s.name       = name
        s.identifier = 'com.test.test'
      end
      assert_equal name.to_s, spec.name
    end
  end

  def test_name_is_verified
    exception = rescue_spec_error_for { |_| }
    assert_match /name is required/, exception.message

    exception = rescue_spec_error_for { |s| s.name = '' }
    assert_match /cannot be an empty string/, exception.message
  end

  def test_name_warns_if_too_long
    err, $stderr = $stderr, StringIO.new
    rescue_spec_error_for { |s| s.name = 'Really long app name' }
    assert_match /should be less than 16 characters/, $stderr.string
  ensure
    $stderr = err
  end

  def test_identifier_is_verified
    exception = rescue_spec_error_for { |s| s.name = 'test' }
    assert_match /identifier is required/, exception.message

    exception = rescue_spec_error_for do |s|
      s.name       = 'test'
      s.identifier = ''
    end
    assert_match /cannot be an empty string/, exception.message
  end

  def test_identifier_limits_character_set
    assert_block do
      Specification.new do |s|
        s.name       = 'test'
        s.identifier = 'com.hotcocoa.test'
      end
    end

    exception = rescue_spec_error_for do |s|
      s.name       = 'test'
      s.identifier = ','
    end
    assert_match /bundle identifier may only/, exception.message
    assert_match /You had ","/, exception.message
  end

  def test_version_defaults_to_1_if_not_set
    spec = Specification.new do |s|
      s.name       = 'test'
      s.identifier = 'com.test.test'
    end
    assert_equal '1.0', spec.version
  end

  def test_version_is_forced_to_a_string
    spec = Specification.new do |s|
      s.name       = 'test'
      s.identifier = 'com.test.test'
      s.version    = 3.1415
    end
    assert_equal '3.1415', spec.version
  end

  def test_short_version_is_empty_by_default
    spec = Specification.new do |s|
      s.name       = 'test'
      s.identifier = 'com.test.test'
    end
    assert_nil spec.short_version
  end

  def test_short_version_is_forced_to_a_string_if_defined
    spec = Specification.new do |s|
      s.name          = 'test'
      s.identifier    = 'com.test.test'
      s.short_version = 3.1415
    end
    assert_equal '3.1415', spec.short_version
  end

  def test_sources_resources_and_data_models_are_initialized_to_an_empty_array_if_not_provided
    spec = Specification.load EMPTY_APP
    assert_empty spec.sources
    assert_empty spec.resources
    assert_empty spec.data_models
  end

  def test_overwirte_attribute
    spec = Specification.load EMPTY_APP
    refute spec.overwrite?

    spec = Specification.load STOPWATCH
    assert spec.overwrite?
  end

  def test_stdlib_attribute
    spec = Specification.load HOTCONSOLE
    assert_equal true, spec.stdlib

    spec = Specification.load STOPWATCH
    assert_equal false, spec.stdlib
  end

  def test_type_attribute
    spec = Specification.load HOTCONSOLE
    assert_equal 'APPL', spec.type

    spec = Specification.load EMPTY_APP
    assert_equal 'BNDL', spec.type
  end

  def test_signature_attribute
    spec = Specification.load EMPTY_APP
    assert_equal '????', spec.signature

    spec = Specification.load HOTCONSOLE
    assert_equal 'girb', spec.signature
  end

  def test_icon_exists?
    spec = Specification.load HOTCONSOLE
    refute spec.icon_exists?

    # works because this project uses the icon from a system app
    spec = Specification.load CALCULATOR
    assert spec.icon_exists?
  end

end
