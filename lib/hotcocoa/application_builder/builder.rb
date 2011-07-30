framework 'Foundation'

require 'fileutils'
require 'rbconfig'

class HotCocoa::Application::Builder

  def self.build spec, opts = {}
    new(spec).build(*opts)
  end

  def initialize spec
    @spec = spec
  end

  def build opts = {}
    raise NotImplementedError, 'Please Implement Me, :('
    deploy if opts[:deploy]
  end


  private

  def deploy
    # Deploying always makes a fresh build...
  end

end
