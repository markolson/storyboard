module Suby
  class Downloader::TVSubtitles < Downloader
    SITE = 'www.tvsubtitles.net'
    FORMAT = :zip
    SEARCH_URL = '/search.php'
    SUBTITLE_TYPES = [:tvshow]

    # cache
    SHOW_URLS = {}
    SHOW_PAGES = {}

    # "Show (2009-2011)" => "Show"
    def clean_show_name show_name
      show_name.sub(/ \(\d{4}-\d{4}\)$/, '')
    end

    def show_url
      SHOW_URLS[show] ||= begin
        results = Nokogiri(post(SEARCH_URL, 'q' => show))
        a = results.css('ul li div a').find { |a|
          clean_show_name(a.text).casecmp(show) == 0
        }
        raise NotFoundError, "show not found" unless a
        url = a[:href]

        raise 'invalid show url' unless /^\/tvshow-\d+\.html$/ =~ url
        url
      end
    end

    def season_url
      show_url.sub(/\.html$/, "-#{season}.html")
    end

    def has_season?
      season_text = "Season #{season}"
      bs = SHOW_PAGES[show].css('div.left_articles p.description b')
      unless bs.find { |b| b.text == season_text }
        raise NotFoundError, "season not found"
      end
    end

    def find_episode_row
      row = SHOW_PAGES[show].css('div.left_articles table tr').find { |tr|
        tr.children.find { |td| td.name == 'td' and
                                td.text =~ /\A#{season}x0?#{episode}\z/ }
      }
      raise NotFoundError, "episode not found" unless row
      row
    end

    def episode_url
      @episode_url ||= begin
        SHOW_PAGES[show] ||= Nokogiri(get(season_url))
        has_season?

        url = nil
        find_episode_row.children.find { |td|
          td.children.find { |a|
            a.name == 'a' and a[:href].start_with?('episode') and url = a[:href]
          }
        }
        unless url =~ /^episode-(\d+)\.html$/
          raise "invalid episode url: #{episode_url}"
        end

        "/episode-#{$1}-#{lang}.html"
      end
    end

    def subtitles_url
      @subtitles_url ||= begin
        subtitles = Nokogiri(get(episode_url))

        # TODO: choose 720p or most downloaded instead of first found
        a = subtitles.css('div.left_articles a').find { |a|
          a.name == 'a' and a[:href].start_with?('/subtitle')
        }
        raise NotFoundError, "no subtitles available" unless a
        url = a[:href]
        raise 'invalid subtitle url' unless url =~ /^\/subtitle-(\d+)\.html/
        url
      end
    end

    def download_url
      URI.escape '/' + get_redirection(subtitles_url.sub('subtitle', 'download'))
    end
  end
end
