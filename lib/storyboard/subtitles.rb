require 'pp'

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

    if false == "the file has subtitles embedded"

    else
      LOG.debug("No subtitles embeded. Using suby.")
      # suby includes a giant util library the guy also wrote
      # that it uses to call file.basename instead of File.basename(file),
      #but "file" has to be a "Path", so, whatever.
      suby_file = Path(options[:file])
      #downloader = Suby::Downloader::OpenSubtitles.new(suby_file, 'en')
      # try Addic7ed first, as, on average, it seems a bit better.
      downloader = nil


      if downloader.nil?
        LOG.info("Searching for subtitles on OpenSubtitles")
        downloader = Suby::Downloader::OpenSubtitles.new(suby_file, 'en')
      end
      pp downloader.possible_urls
      LOG.debug("Found #{downloader.download_url}")
      #LOG.debug(downloader.found)
      downloader.extract(downloader.download_url)
    end
  end

  private

  def best_subtitle_match

    {perfect: true, url: ""}
  end

  public


  class SRT
    Page = Struct.new(:index, :start_time, :end_time, :lines)

    TIME_REGEX = /\d{2}:\d{2}:\d{2}[,\.]\d{1,4}/
    attr_accessor :text, :pages, :options

    def initialize(contents, parent_options)
      @options = parent_options
      @text = contents
      @pages = []
      parse
      clean_promos
      LOG.info("Parsed subtitle file. #{count} entries found.")
    end

    #There are some horrid files, so I want to be able to have more than just a single regex
    #to parse the srt file. Eventually, handling these errors will be a thing to do.
    def parse
      phase = :line_no
      page = nil
      @text.each_line {|l|
        l.gsub!("\xEF\xBB\xBF".force_encoding("UTF-8"), '') if page.nil?
        # Some files have BOM markers. Why? Why would you add a BOM marker.
        l = l.encode("UTF-32", :invalid=>:replace, :replace=>"?").encode("UTF-8")
        l = l.strip
        case phase
        when :line_no
          if l =~ /^\d+$/
            page = Page.new(@pages.count + 1, nil, nil, [])
            phase = :time
          elsif !l.empty?
            raise "Bad SRT File: Should have a block number but got '#{l}' [#{l.bytes.to_a.join(',')}]"
          end
        when :time
          if l =~ /^(#{TIME_REGEX}) --> (#{TIME_REGEX})$/
            page[:start_time] = STRTime.parse($1) + @options[:nudge]
            page[:end_time] = STRTime.parse($2) + @options[:nudge]
            phase = :text
          else
            raise "Bad SRT File: Should have time range but got '#{l}'"
          end
        when :text
          if l.empty?
            phase = :line_no
            @pages << page
          else
            page[:lines] <<  l.gsub(/<\/?[^>]+?>/, '')
          end
        end
      }
    end

    # Strip out obnoxious "CREATED BY L33T DUD3" or "DOWNLOADED FROM ____" text
    def clean_promos
      @pages.delete_if {|page|
        !page[:lines].grep(/Subtitles downloaded/).empty? ||
        !page[:lines].grep(/addic7ed/).empty? ||
        !page[:lines].grep(/OpenSubtitles/).empty? ||
        !page[:lines].grep(/sync, corrected by/).empty? ||
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
