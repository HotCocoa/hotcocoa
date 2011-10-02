require 'hotcocoa/application/builder'

class TestApplicationBuilder < MiniTest::Unit::TestCase
  include Application

  TEST_DIR = File.join(ENV['TMPDIR'], 'test_app_specification')

  # Some HotCocoa appspec files, converted from build.yml files borrowed from projects on Github
  HOTCONSOLE = 'test/fixtures/hotconsole.appspec'
  STOPWATCH  = 'test/fixtures/stopwatch.appspec'

  def setup;    FileUtils.mkdir TEST_DIR; end
  def teardown; FileUtils.rm_rf TEST_DIR; end

  def test_caches_spec
    spec = Specification.load STOPWATCH
    builder = Builder.new spec
    assert_equal spec, builder.spec
  end

  def test_deploy_options
    spec = Specification.load STOPWATCH
    builder = Builder.new spec
    options = builder.send :deploy_options
    assert options.include? "--gem rest-client"
  end

end
