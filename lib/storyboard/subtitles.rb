require 'pp'
require 'iconv'

class Storyboard
  def get_subtitles
    extensionless = File.join(File.dirname(options[:file]), File.basename(options[:file], ".*") + '.srt')

    if mkv?
      if Storyboard.mkvtools_installed?
        output = `mkvmerge -i "#{options[:file]}"`
        subs = output.scan(/Track ID (\d+): subtitles \(S_TEXT\/UTF8\)/)
        # until I can play with better output, take the first.
        if not subs.empty?
          LOG.info("Extracting embedded subtitles")
          LOG.info("Multiple subtitles found in the mkv. Taking the first.") if subs.count > 1
          `mkvextract tracks "#{options[:file]}" #{subs.first[0]}:"#{options[:work_dir]}/subtitles.srt"`
          return File.read("#{options[:work_dir]}/subtitles.srt", )
        end
      else
        LOG.debug("File is mkv, but no mkvtoolnix installed.")
      end
    end

    if File.exists?(options[:file] + '.srt')
      return File.read(options[:file] + '.srt')
    elsif File.exists?(extensionless)
     return File.read(extensionless)
    end

    # suby includes a giant util library the guy also wrote
    # that it uses to call file.basename instead of File.basename(file),
    #but "file" has to be a "Path", so, whatever.
    suby_file = Path(options[:file])
    downloader = Suby::Downloader::OpenSubtitles.new(suby_file, 'en')
    chosen = nil

    if @cache.subtitles.nil?
      LOG.info("No subtitles cache found")
      @cache.subtitles = downloader.possible_urls
      @cache.save
    end
    chosen = pick_best_subtitle(@cache.subtitles)
    contents = @cache.download_file(chosen) do
      downloader.extract(chosen)
    end
    contents
  end

  private

  def pick_best_subtitle(given)
    given = sort_matches(given)
    if given.length == 0
      raise "No subtitles found."
    elsif given.length == 1
      return given[0]['SubDownloadLink']
    elsif given.length > 1
      sub = nil
      puts "There are multiple subtitles that could work with this file. Please choose one!"
      puts "All of these are subtitles made for this exact video file, so any should work." if given[0]['MatchedBy'] == 'moviehash'
      while not sub
        given.each_with_index {|s, i|
          puts "#{i+1}: '#{s['SubFileName']}', added #{s['SubAddDate']}"
        }
        print "choice (default 1): "
        input = gets.chomp
        number = input.empty? ? 1 : input.to_i
        if number > given.count || number < 1
          puts "Try again. Choose a subtitle between 1 and #{given.count}"
        else
          sub = given[number-1]['SubDownloadLink']
        end
      end
      return sub
    end
  end

  def sort_matches(x)
    # filter to only {"MatchedBy"=>"moviehash"}, if possible
    # select only matching filesizes, if nonzero and matching
   x
  end

  public


  class SRT
    Page = Struct.new(:index, :start_time, :end_time, :lines)

    SPAN_REGEX = '[[:digit:]]+:[[:digit:]]+:[[:digit:]]+[,\.][[:digit:]]+'
    attr_accessor :text, :pages, :options, :encoding

    def initialize(contents, parent_options)
      @options = parent_options
      @text = contents
      @pages = []
      @needs_KFhimaji = false
      check_bom(@text.lines.first)
      Storyboard.current_encoding = @encoding
      @text = text.force_encoding(Storyboard.current_encoding)
      parse
      clean_promos
      LOG.info("Parsed subtitle file. #{count} entries found.")
    end


    def check_bom(line)
      bom_check = line.force_encoding("UTF-8").lines.to_a[0].bytes.to_a
      @encoding = 'UTF-8'
      if bom_check[0..1] == [255,254]
        @encoding = "UTF-16LE"
        ret = line[2..6]
      elsif bom_check[0..2] == [239,187,191]
        @encoding = "UTF-8"
        ret = line[3..6]
      end
      line
    end


    def fix_encoding(l)
      # The only  ISO8859-1  I hit so far. I expec this to grow.
      if l.bytes.member? 233
        l = l.unpack("C*").pack("U*")
      end
      l
    end

    #There are some horrid files, so I want to be able to have more than just a single regex
    #to parse the srt file. Eventually, handling these errors will be a thing to do.
    def parse
      phase = :line_no
      page = nil
      @text.each_line {|l|
        l = fix_encoding(l)
        l = l.strip
        #p l.bytes.to_a
        case phase
        when :line_no
          l = l.gsub(Storyboard.encode_regexp('\W'),'')
          if l =~ Storyboard.encode_regexp('^\d+$')
            page = Page.new(@pages.count + 1, nil, nil, [])
            phase = :time
          elsif !l.empty?
            raise "Bad SRT File: Should have a block number but got '#{l.force_encoding('UTF-8')}' [#{l.bytes.to_a.join(',')}]"
          end
        when :time

          l = l.gsub(Storyboard.encode_regexp('[^\,\:[0-9] \-\>]'), '')
          if l =~ Storyboard.encode_regexp("^(#{SPAN_REGEX}) --> (#{SPAN_REGEX})$")
            page[:start_time] = STRTime.parse($1) + @options[:nudge]
            page[:end_time] = STRTime.parse($2) + @options[:nudge]
            phase = :text
          else
            raise "Bad SRT File: Should have time range but got '#{l}'".force_encoding(Storyboard.current_encoding)
          end
        when :text
          if l.empty?
            phase = :line_no
            @pages << page
          else
            Storyboard.needs_KFhimaji(true) if l.contains_cjk?
            page[:lines] << l.gsub(Storyboard.encode_regexp("<\/?[^>]*>"), "")
          end
        end
      }
    end

    # Strip out obnoxious "CREATED BY L33T DUD3" or "DOWNLOADED FROM ____" text
    def clean_promos
      @pages.delete_if {|page|
        !page[:lines].grep(Storyboard.encode_regexp('Subtitles downloaded')).empty? ||
        !page[:lines].grep(Storyboard.encode_regexp('addic7ed')).empty? ||
        !page[:lines].grep(Storyboard.encode_regexp('OpenSubtitles')).empty? ||
        !page[:lines].grep(Storyboard.encode_regexp('sync, corrected by')).empty? ||
        false
      }
    end

    def save
      File.open(File.join(options[:work_dir], options[:basename] + '.srt'), 'w') {|f|
        f.write(self.to_s)
      }
      self
    end

    def to_s
       text
    end

    def count
      @pages.count
    end
  end

end
