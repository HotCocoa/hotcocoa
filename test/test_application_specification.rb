require 'hotcocoa/application_builder/specification'

class TestApplicationSpecification < MiniTest::Unit::TestCase

  AppSpec = HotCocoa::Application::Specification
  TEST_DIR      = File.join( File.dirname(__FILE__), 'test_app_specification' )

  # Some HotCocoa appspec files, converted from build.yml files borrowed from projects on Github
  HOTCONSOLE = 'test/fixtures/hotconsole.appspec'
  CALCULATOR = 'test/fixtures/calculator.appspec'
  STOPWATCH  = 'test/fixtures/stopwatch.appspec'
  EMPTY_APP  = 'test/fixtures/empty.appspec'

  def setup;    FileUtils.mkdir TEST_DIR; end
  def teardown; FileUtils.rm_rf TEST_DIR; end

  def test_reads_attributes
    spec = AppSpec.load HOTCONSOLE
    assert_equal 'HotConsole',                spec.name
    assert_equal '1.0',                       spec.version
    assert_equal 'resources/HotConsole.icns', spec.icon

    spec = AppSpec.load CALCULATOR
    assert_equal 'Calculator', spec.name
    assert_equal '2.0', spec.version
  end

  def test_version_defaults_to_1_if_not_set
    spec = AppSpec.load STOPWATCH
    refute_nil spec.version
    assert_equal '1.0', spec.version
  end

  def test_sources_resources_and_data_models_are_initialized_to_an_empty_array_if_not_provided
    spec = AppSpec.load EMPTY_APP
    assert_empty spec.sources
    assert_empty spec.resources
    assert_empty spec.data_models
  end

  def test_overwirte_attribute
    spec = AppSpec.load EMPTY_APP
    refute spec.overwrite?

    spec = AppSpec.load STOPWATCH
    assert spec.overwrite?
  end

  def test_stdlib_attribute
    spec = AppSpec.load HOTCONSOLE
    assert_equal true, spec.stdlib

    spec = AppSpec.load STOPWATCH
    assert_equal false, spec.stdlib
  end

  def test_type_attribute
    spec = AppSpec.load HOTCONSOLE
    assert_equal 'APPL', spec.type

    spec = AppSpec.load EMPTY_APP
    assert_equal 'BNDL', spec.type
  end

  def test_signature_attribute
    spec = AppSpec.load EMPTY_APP
    assert_equal '????', spec.signature

    spec = AppSpec.load HOTCONSOLE
    assert_equal 'girb', spec.signature
  end

  def test_icon_exists?
    spec = AppSpec.load HOTCONSOLE
    refute spec.icon_exists?

    # works because this project uses the icon from a system app
    spec = AppSpec.load CALCULATOR
    assert spec.icon_exists?
  end

end
