class TestHotCocoaBinary < MiniTest::Unit::TestCase

  def hotcocoa *args
    ruby = ENV['RUBY_VERSION'] ? 'ruby' : 'macruby'
    `#{ruby} -I#{SOURCE_ROOT}/lib #{SOURCE_ROOT}/bin/hotcocoa #{args.join(' ')}`.chomp
  end

end


class TestHotCocoaBinaryOptions < TestHotCocoaBinary

  def test_shows_version
    pattern = /Hot\s?Cocoa\s+#{HotCocoa::VERSION}/i
    assert_match pattern, hotcocoa('-v')
    assert_match pattern, hotcocoa('--version')
  end

  def test_shows_usage
    assert_equal 'Usage: hotcocoa <project name>', hotcocoa
    assert_equal 'Usage: hotcocoa <project name>', hotcocoa('-h')
    assert_equal 'Usage: hotcocoa <project name>', hotcocoa('--help')
  end

end


class TestHotCocoaBinaryUsesTemplate < TestHotCocoaBinary

  def setup
    @dir = File.join(ENV['TMPDIR'], 'hot_cocoa_test')
    Dir.mkdir @dir
  end

  def teardown
    FileUtils.rm_rf @dir
  end

  def test_uses_given_name
    app_name = 'The answer to life, the universe, and everything'
    Dir.chdir(@dir) do
      hotcocoa app_name.inspect
      assert Dir.exists? app_name
    end
  end

  def test_uses_camel_case_name_for_appspec
    app_name = 'CamelCase'
    Dir.chdir(@dir) do
      hotcocoa app_name.inspect
      assert Dir.new(app_name).entries.include? "#{app_name}.appspec"
    end
  end

  def test_converts_non_alphanumeric_characters_to_camelcase
    app_name = 'The answer to life, the universe, and everything'
    Dir.chdir(@dir) do
      hotcocoa app_name.inspect
      assert Dir.new(app_name).entries.include? "TheAnswerToLifeTheUniverseAndEverything.appspec"
    end
  end

  # this is a weird edge case that was programmed in
  # so we will preseve it for the time being
  def test_moves_existing_rb_file_into_the_project
    app_name = 'blah blah.rb'
    Dir.chdir(@dir) do
      File.open(app_name, 'w') { |f| f.write 'ZOMG' }
      hotcocoa app_name.inspect
      app = File.read(File.join(app_name.chomp('.rb'),'lib','application.rb'))
      assert_equal 'ZOMG', app
    end
  end

end
