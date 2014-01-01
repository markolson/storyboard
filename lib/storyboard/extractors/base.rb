module Storyboard::Extractor
  class Base
  	attr_accessor :runner

    attr_accessor :pre, :post, :filters

  	def initialize(runner)
  		@runner = runner
      @pre, @post, @filters = [], [], []

      @filters << "scale=#{@runner.width}:#{@runner.height || -1}" if @runner.options[:dimensions_given]
  	end

    def build_ffmpeg_command(params={})
      extra_filters = params[:filters] || []

      parts =  ["-v", "quiet", "-y"]
      #parts =  ["-y"]
      parts += (params[:pre] || []) + @pre
      parts += ["-i", @runner.video.path]
      parts += ["-an", "-vf", (@filters | extra_filters).join(',')]
      parts += (params[:post] || []) + @post
      parts += [File.join(@runner.workdirectory, params[:filename]) || []]
    end

    def format
      "tmp*.jpg"
    end
  end
end