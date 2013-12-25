module Storyboard::Builder
  class GIF
    attr_accessor :parent
    def initialize(parent)
      @parent = parent
    end

    def run(scanfor='*.jpg')
      scanpath = File.join(@parent.workdirectory, scanfor)
      writepath = File.join(@parent.options['_output_director'], "a.gif")
      Storyboard::Binaries.convert("-fuzz", "5%", "-layers", "OptimizeTransparency", "+map", "-coalesce", scanpath, writepath)
    end
  end
end