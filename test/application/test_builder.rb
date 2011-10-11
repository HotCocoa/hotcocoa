require 'test/application/helper'

class TestApplicationBuilder < TestApplicationModule

  def hotconsole
    @@hotconsole ||= Builder.new hotconsole_spec
  end
  def stopwatch
    @@stopwatch  ||= Builder.new stopwatch_spec
  end

  def test_caches_spec
    assert_equal stopwatch_spec, stopwatch.spec
  end

  # I don't think it is too important to test deployment as well
  # as long as we make sure we are passing the correct options
  # to `macruby_deploy`

  def test_deploy_option_gems
    assert_includes stopwatch.send(:deploy_options),  '--gem rest-client'
    refute_includes hotconsole.send(:deploy_options), '--gem'
  end

  def test_deploy_option_compile
    assert_includes stopwatch.send(:deploy_options),  '--compile'
    refute_includes hotconsole.send(:deploy_options), '--compile'
  end

  def test_deploy_option_embed_bs
    refute_includes stopwatch.send(:deploy_options),  '--bs'
    assert_includes hotconsole.send(:deploy_options), '--bs'
  end

  def test_deploy_option_stdlib
    assert_includes stopwatch.send(:deploy_options),  '--no-stdlib'
    refute_includes hotconsole.send(:deploy_options), 'stdlib'

    spec = minimal_spec do |s|
      s.stdlib = ['matrix', 'base64']
    end
    options = Builder.new(spec).send :deploy_options
    refute_includes options, '--no-stdlib'
    assert_includes options, '--stdlib matrix'
    assert_includes options, '--stdlib base64'
  end

  def test_plist_only_uses_icon_if_it_can
    plist = load_plist(hotconsole.send(:info_plist))
    refute_includes plist, :CFBundleIconFile

    spec = hotconsole_spec.dup
    spec.icon = '/Applications/Calculator.app/Contents/Resources/Calculator.icns'
    plist = load_plist(Builder.new(spec).send(:info_plist))
    assert_includes plist, :CFBundleIconFile
  end

  def test_plist_hash_from_spec_overrides_all
    spec = hotconsole_spec.dup
    spec.plist[:MyKey]            = true
    spec.plist[:NSPrincipleClass] = 'Foo'
    spec.plist[:CFBundleName]     = 'Cake'

    plist = load_plist(Builder.new(spec).send(:info_plist))
    assert_equal true,            plist[:MyKey             ]
    assert_equal 'Foo',           plist[:NSPrincipleClass  ]
    assert_equal 'Cake',          plist[:CFBundleName      ]
    assert_equal spec.identifier, plist[:CFBundleIdentifier]
  end

  def test_plist_doctype_generated_if_present
    spec = minimal_spec do |s|
      s.declare_doc_type do |doc_type|
        doc_type.extensions = ["ext"]
        doc_type.icon       = "MyIcon.icns"
        doc_type.name       = "MyProjectDocument"
        doc_type.role       = :viewer
        doc_type.class      = "MyDocument"
      end
    end
    plist = load_plist(Builder.new(spec).send(:info_plist))
    assert_equal 1, plist[:CFBundleDocumentTypes].size
  end
end
