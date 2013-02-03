require 'storyboard/subtitles.rb'
require 'storyboard/bincheck.rb'
require 'storyboard/thread-util.rb'
require 'storyboard/time.rb'
require 'storyboard/version.rb'
require 'storyboard/cache.rb'

require 'storyboard/generators/sub.rb'
require 'storyboard/generators/gif.rb'

require 'mime/types'
require 'fileutils'
require 'tmpdir'

require 'ruby-progressbar'
require 'mini_magick'

require 'json'

class Gifboard < Storyboard
  attr_accessor :options, :capture_points, :subtitles, :timings
  attr_accessor :length, :renderers, :mime, :cache

  def initialize(o)
    super
  end

  def run
    LOG.info("Processing #{options[:file]}")
    setup

    @cache = Cache.new(Suby::MovieHasher.compute_hash(Path.new(options[:file])))

    LOG.debug(options) if options[:verbose]

    @subtitles = SRT.new(options[:subs] ? File.read(options[:subs]) : get_subtitles, options)
    # bit of a temp hack so I don't have to wait all the time.
    @subtitles.save if options[:verbose]

    @cache.save

    if @options[:text]
      @renderers << Storyboard::GifRenderer.new(self)

      selected = choose_text
      @capture_points << selected.start_time
      (0.1).step(selected.end_time.value - selected.start_time.value, 0.1) {|i|
        @capture_points << selected.start_time + i
      }
      # @capture_points << selected.end_time not sure if it's better or worse to leave this yet

      @stop_frame = @capture_points.count
      extract_frames

      render_output
    else
      @subtitles.pages.each {|x|
        print "[#{x.start_time.to_srt}]\t"
        x.lines.each_with_index{|l,i|
          print "\t\t" if i > 0
          puts l
        }
      }
      puts "\n\nYou need to specify what text to look for with the -t option. Listing all subtitles instead."
      puts "ex: gifboard -t 'a funny joke ha. ha' video.mkv"
    end
  end

  def choose_text
    matches = []
    @subtitles.pages.each {|x|
      found = !x.lines.select {|l|
        l.downcase.match(options[:text].downcase)
      }.empty?
      matches << x if found
    }

    match = nil
    if matches.count == 0
      raise "No matches found"
    elsif matches.count == 1
      puts "Just one match found. Using it."
      match = matches.first
    else
      puts "Multiple matches found.. pick one!"
      matches.each_with_index {|m,i|
        print "#{i+1}:\t"
        m.lines.each_with_index{|l,j|
          print "\t" if j > 0
          puts l
        }
      }
      while !match
        print "choice (default 1): "
        input = gets.chomp
        number = input.empty? ? 1 : input.to_i
        if number > matches.count || number < 1
          puts "Try again. Choose a subtitle between 1 and #{matches.count}"
        else
          match = matches[number-1]
        end
      end
    end
    match
  end
end
