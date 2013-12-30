module Storyboard::Runners
  class Gif < Storyboard::Runners::Base
    def run
      # do secondary checks.
      raise Trollop::CommandlineError, "--use_first_text_match requires --find-text" if @options[:use_first_text_match] && @options[:find_text].nil?
      
      @extractor = Storyboard::Extractor::Range.new(self)
      pull_options!
      @extractor.fps = @video.framerate_r(2)
      @extractor.post += ["-q", 1]
      
      @sub = nil

=begin
  oooookay so this isn't going to scale.
  s = Subtitles.load # runs through subtitle_path, local  file, and downloading
  s.filter &block
  s.filter do {|sub|
    (s[:start] <= end_time) &&  (s[:end] >= start_time)
  }

  s.filter do {|sub|
    s =~ /cape?/
  }  
  s.commit (?)
=end

      ui.log("Checking for subtitles")
      @subtitles = Storyboard::Subtitles.new(self)
      load_from = [
        Storyboard::Subtitles::Source::Text,
        Storyboard::Subtitles::Source::Path,
        Storyboard::Subtitles::Source::Local,
        #Storyboard::Subtitles::Source::OSDb,
      ]
      @subtitles.load_from(load_from)

      @subtitles.write
=begin
      #@subtitles = @subtitles.apply(Storyboard::Subtitles::FindText) if @options[:find_text]

      #exit

      if @options[:use_text_given]
        raise Trollop::CommandlineError, "--start cannot be further than --end" if start_time >= end_time
        @sub = Storyboard::Subtitles::Base.new(self)
        @sub.add_line(start_time, end_time, options[:use_text])
      elsif @options[:subtitle_path_given]
        @sub = Storyboard::Subtitles::File.new(self)
        @sub.load_subs(@options[:subtitle_path])
      else
        @sub = Storyboard::Subtitles::Web.new(self)
        path = @options['_video']
        # check if there's a subtitle file in the same folder
        subtitle_file_extension = %w(srt sub ssa ass).select{ |ext| ext = ".#{ext}"; File.exist?(path.gsub(File.extname(path), ext)) }.first
        if subtitle_file_extension
          #f = Storyboard::Subtitles::File.new(self)
          #f.load_subs(@sub.osdb.sub_path(subtitle_file_extension))
          #f.write
        else
          @sub.download
        end
      end


      @sub.write if @sub

      # search based on the -f flag
=end
      ui.log("Building frames")
      @extractor.run
      ui.log("Outputting GIF")
      @gif = Storyboard::Builder::GIF.new(self).run(@extractor.format)
    end

    def name
    	"Gifboard"
    end
  end
end
