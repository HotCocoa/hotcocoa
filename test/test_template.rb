require 'fileutils'
require 'hotcocoa/template'


# feels weird to have a test class with only one test...
class TestHotCocoaTemplateDir < MiniTest::Unit::TestCase

  # important due to differences in compiled code
  def test_template_directory_is_correct
    what_git_thinks      = File.join(SOURCE_ROOT, 'template')
    what_hotcocoa_thinks = HotCocoa::Template.template_directory
    assert_equal what_git_thinks, what_hotcocoa_thinks
  end

end


class TestHotCocoaTemplateMaker < MiniTest::Unit::TestCase

  def setup
    @dir = File.join(ENV['TMPDIR'], 'template_test')
    @template = HotCocoa::Template.new @dir, app_name
    @template.copy!
  end

  def teardown
    FileUtils.rm_rf @dir
  end

  def app_name
    'AWESOME SAUCE'
  end

  def all_files_in dir
    Dir.glob(File.join(dir, '**/*'))
  end

  def test_uses_app_name_for_appspec_file
    assert File.exists? File.join(@dir,"#{app_name}.appspec")
  end

  def test_copy_to_substitutes_app_name_properly
    content = ''
    all_files_in(@dir).each do |file|
      next if File.extname(file) == '.icns'
      next if File.directory? file
      content << IO.read(file)
    end
    refute_match /__APPLICATION_NAME__/, content
    # this is a weak assertion, what can we do to make it stronger?
    assert_match /#{app_name}/, content
  end

  def test_copy_to_copies_everything
    template = all_files_in(File.join(SOURCE_ROOT, 'template'))
    template.map! { |file| file.sub /^#{File.join(SOURCE_ROOT, 'template')}/, '' }

    copy = all_files_in(@dir)
    copy.map!    { |file| file.sub @dir, '' }
    copy.reject! { |file| file.match /appspec/ } # appspec is a special case

    assert_empty copy - template
  end

end
