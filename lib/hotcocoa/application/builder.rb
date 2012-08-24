framework 'Foundation'

require 'fileutils'
require 'rbconfig'
require 'hotcocoa/application/specification'

module Application
  ##
  # This class is responsible for building application bundles, but could
  # theoretically be used to build other bundles, such as frameworks, with
  # only a few changes.
  #
  # It is designed to work in conjunction with an {Application::Specification}
  # object which would provide details on how to build the bundle.
  class Builder

    ##
    # Build an application from a specification, optionally for
    # deployment.
    #
    # @param [Application::Specification] spec
    # @param [Hash] opts
    # @option opts [Symbol] :deploy (false)
    def self.build spec, opts = {}
      new(spec).build(opts)
    end

    ##
    # Cached spec.
    #
    # @return [Application::Specification]
    attr_reader :spec

    # @param [Application::Specification]
    def initialize spec
      @spec = case spec
              when Specification
                spec
              when String
                Specification.load spec
              end
    end

    # @param [Hash]
    # @option opts [Symbol] :deploy (false)
    def build opts = {}
      if spec.overwrite? || opts[:deploy] # Deploying always makes a fresh build
        remove_bundle_root
      end
      build_bundle_structure
      write_bundle_files
      copy_sources
      copy_resources
      compile_data_models
      copy_icon_file if spec.icon_exists?
      deploy if opts[:deploy]
    end

    ##
    # Run the bundle's binary directly so `STDOUT` and `STDERR` appear in the
    # terminal.
    def run
      system "./#{executable_file}"
    end

    ##
    # Destroy the existing bundle, if it exists.
    def remove_bundle_root
      FileUtils.rm_rf bundle_root if File.exist?(bundle_root)
    end


    private

    ##
    # Call `macruby_deploy` to lend a helping hand.
    def deploy
      system "macruby_deploy --embed --gem hotcocoa #{deploy_options} #{bundle_root}"
    end

    ##
    # Build the options list to pass to `macruby_deploy`.
    def deploy_options
      options = []
      spec.gems.each { |g| options << "--gem #{g}" }
      options << '--bs'        if spec.embed_bridgesupport?
      options << '--compile'   if spec.compile?
      options << '--no-stdlib' unless spec.stdlib
      if spec.stdlib.respond_to? :each
        spec.stdlib.each do |lib|
          options << "--stdlib #{lib}"
        end
      end
      options.join(' ')
    end

    ##
    # Setup the basic directory structure of a bundle.
    def build_bundle_structure
      [bundle_root, contents_root, frameworks_root, macos_root, resources_root].each do |dir|
        Dir.mkdir(dir) unless File.exist?(dir)
      end
    end

    ##
    # Setup the remaining standard files for the bundle.
    def write_bundle_files
      write_pkg_info_file
      write_info_plist_file
      build_executable unless File.exist?(executable_file)
      write_ruby_main
    end

    ##
    # Copy the sources, usually just the ruby source code, into the bundle.
    def copy_sources
      spec.sources.each do |source|
        destination = File.join(resources_root, source)
        FileUtils.mkdir_p(File.dirname(destination)) unless File.exist?(File.dirname(destination))
        FileUtils.cp_r source, destination
      end
    end

    ##
    # @todo An example project that uses a `xib`.
    #
    # Copy the resources, such as images and data, into the bundle.
    # Resources can also include interface builder files, which will
    # be compiled for you.
    def copy_resources
      spec.resources.each do |resource|
        destination = File.join(resources_root, resource.split('/')[1..-1].join('/'))
        FileUtils.mkdir_p(File.dirname(destination)) unless File.exist?(File.dirname(destination))

        if resource =~ /\.xib$/
          destination.gsub!(/.xib/, '.nib')
          system "ibtool --compile #{destination} #{resource}"
        else
          FileUtils.cp_r resource, destination
        end
      end
    end

    ##
    # Compile any CoreData model files and copy them to the bundle.
    def compile_data_models
      spec.data_models.each do |data|
        system "/Developer/usr/bin/momc #{data} #{resources_root}/#{File.basename(data, ".xcdatamodel")}.mom"
      end
    end

    ##
    # Copy the icon file to the bundle.
    def copy_icon_file
      FileUtils.cp spec.icon, icon_file
    end

    ##
    # Generate the `PkgInfo` file for the bundle. Every bundle needs this
    # in order identify its type of bundle and signature.
    def write_pkg_info_file
      File.open(pkg_info_file, 'wb') do |file|
        file.write "#{spec.type}#{spec.signature}"
      end
    end

    ##
    # @todo Development region needs to be configurable in the future. And
    #       so should the default class. They should still both have defaults.
    #
    # Generate and the `Info.plist` for the bundle using fields from the
    # cached app spec.
    def info_plist
      # http://developer.apple.com/library/mac/#documentation/General/Reference/InfoPlistKeyReference/Articles/AboutInformationPropertyListFiles.html%23//apple_ref/doc/uid/TP40009254-SW1
      info = {
        CFBundleName:                  spec.name,
        CFBundleIdentifier:            spec.identifier,
        CFBundleVersion:               spec.version,
        CFBundlePackageType:           spec.type,
        CFBundleSignature:             spec.signature,
        CFBundleExecutable:            executable_file_name,
        CFBundleDevelopmentRegion:     'English',
        CFBundleInfoDictionaryVersion: '6.0',
        NSPrincipalClass:              'NSApplication',
        LSUIElement:                   spec.agent,
        LSMinimumSystemVersion:        '10.6.7', # @todo should match MacRuby
      }
      info[:CFBundleIconFile] = File.basename(spec.icon) if spec.icon_exists?
      info[:CFBundleDocumentTypes] = spec.doc_types.map(&:info_plist_representation) unless spec.doc_types.empty?
      info[:CFBundleShortVersionString] = spec.short_version unless spec.short_version.nil?
      info[:NSHumanReadableCopyright] = spec.copyright unless spec.copyright.nil?
      info.merge! spec.plist # should always be done last
      info.to_plist
    end

    ##
    # Wirte out the generated info plist for the bundle.
    def write_info_plist_file
      File.open(info_plist_file, 'w') do |file|
        file.write info_plist
      end
    end

    ##
    # @todo Need a better way of specifying the supported architectures,
    #       hard coding makes HotCocoa susceptible to the same problem
    #       as before.
    #
    # Create the standard bootstrap binary to launch a MacRuby app and place
    # it in the bundle.
    def build_executable
      File.open(objective_c_source_file, 'wb') do |f|
        f.write %{
            #import <MacRuby/MacRuby.h>

            int main(int argc, char *argv[])
            {
                return macruby_main("rb_main.rb", argc, argv);
            }
        }
      end
      Dir.chdir(macos_root) do
        system "#{RbConfig::CONFIG['CC']} main.m -o #{executable_file_name} -arch x86_64 -framework MacRuby -framework Foundation -fobjc-gc-only"
      end
      File.unlink(objective_c_source_file)
    end

    ##
    # Borrow `rb_main` from MacRuby Xcode templates and use it to load all
    # the sources in the bundle at boot time.
    def write_ruby_main
      File.open(main_ruby_source_file, 'wb') do |f|
        f.write <<-EOF
    framework 'Cocoa'
    framework 'MacRuby'

    def deployed?
      !NSBundle.allFrameworks.find { |x|
        x.bundleIdentifier == 'org.macruby' &&
        x.bundlePath.match(/^\\/Library\\/Frameworks/)
      }
    end

    # Loading all the Ruby project files.
    main = File.basename(__FILE__, File.extname(__FILE__))
    dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
    dir_path += '/lib/'
    Dir.glob(File.join(dir_path, '*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|
      if path != main
        require File.join(dir_path, path)
      end
    end

    # Starting the Cocoa main loop.
    NSApplicationMain(0, nil)
        EOF
      end
    end

    ##
    # Path where to put the bundle.
    def bundle_root
      "#{spec.name}.app"
    end

    ##
    # Path where to put the `Contents' directory of the bundle.
    def contents_root
      File.join(bundle_root, 'Contents')
    end

    ##
    # Path where to put the `Frameworks' directory of the bundle.
    def frameworks_root
      File.join(contents_root, 'Frameworks')
    end

    ##
    # Path where to put the `MacOS' directory of the bundle.
    def macos_root
      File.join(contents_root, 'MacOS')
    end

    ##
    # Path where to put the `Resources' directory of the bundle.
    def resources_root
      File.join(contents_root, 'Resources')
    end

    ##
    # Path where to put the `Info.plist' directory of the bundle.
    def info_plist_file
      File.join(contents_root, 'Info.plist')
    end

    ##
    # Path where to put the icon for the bundle.
    def icon_file
      File.join(resources_root, "#{spec.name}.icns")
    end

    ##
    # Path where to put the `PkgInfo` file for the bundle.
    def pkg_info_file
      File.join(contents_root, 'PkgInfo')
    end

    ##
    # Generate the name of the binary. Done by removing whitespace from
    # the `name` attribute of the cached app spec.
    def executable_file_name
      spec.name.gsub(/\s+/, '')
    end

    ##
    # Path where to put the binary file for the bundle.
    def executable_file
      File.join(macos_root, executable_file_name)
    end

    ##
    # Temporary path where the temporary source for bootstrap binary.
    def objective_c_source_file
      File.join(macos_root, 'main.m')
    end

    ##
    # Path where to put the `rb_main.rb` bootstrap file.
    def main_ruby_source_file
      File.join(resources_root, 'rb_main.rb')
    end
  end
end
