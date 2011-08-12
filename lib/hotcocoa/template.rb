require 'fileutils'
require 'rbconfig'

##
# The set of methods used for setting up a new HotCocoa app from
# the template.
class HotCocoa::Template

  ##
  # The path to the HotCocoa source files
  #
  # @return [String]
  def self.source_directory
    file = $LOADED_FEATURES.find { |file| file.match /hotcocoa\/template\.rbo?$/ }
    File.expand_path(File.join(File.dirname(file), '../..'))
  end

  ##
  # The path to the HotCocoa app template in the HotCocoa source files
  #
  # @return [String]
  def self.template_directory
    File.join(source_directory, 'template')
  end

  ##
  # Iterate recursively over each file in a directory.
  #
  # @yield Will yield once per file
  # @yieldparam [String] file the path to a file
  # @return [Array<String>]
  def self.all_files_in dir
    Dir.glob(File.join(dir, '**', '*')).each { |file| yield file }
  end

  ##
  # Copy all the files from the template to the destination, and substitute
  # all placeholder tokens (e.g. the name of the app).
  #
  # @param [String] directory new root directory for the project
  # @param [String] app_name
  def self.copy_to directory, app_name
    FileUtils.mkdir_p directory

    company_name = ENV['USER'] || 'yourcompany'
    all_files_in(template_directory) do |file|
      short_name  = file.sub(/^#{template_directory}/, '')
      short_name.gsub! /__APPLICATION_NAME__/, app_name
      destination = File.join(directory, short_name)

      if File.directory? file
        FileUtils.mkdir_p destination

      else
        File.open(destination, 'w') do |out|
          input = File.read(file)
          input.gsub! /__APPLICATION_NAME__/, app_name
          input.gsub! /__COMPANY_NAME__/, company_name
          out.write input
        end
      end
    end
  end
end
