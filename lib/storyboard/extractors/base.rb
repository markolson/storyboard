module Storyboard::Extractor
  class Base
  	attr_accessor :parent

    attr_accessor :pre, :post, :filters

  	def initialize(parent)
  		@parent = parent
      @pre, @post, @filters = [], [], []

      @filters << "scale=#{@parent.width}:#{@parent.height || -1}"
  	end

    def build_ffmpeg_command(params={})

      parts =  ["-v", "quiet", "-y"]
      #parts =  ["-y"]
      parts += (params[:pre] || []) + @pre
      parts += ["-i", @parent.video.path]
      parts += ["-vf", @filters.join(',')]
      parts += (params[:post] || []) + @post
      parts += [File.join(@parent.workdirectory, params[:filename]) || []]
    end

    def format
      "tmp*.jpg"
    end
  end
end