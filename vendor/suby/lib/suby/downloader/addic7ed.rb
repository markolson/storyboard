module Suby
  class Downloader::Addic7ed < Downloader
    SITE = 'www.addic7ed.com'
    FORMAT = :file
    SUBTITLE_TYPES = [:tvshow]

    LANG_IDS = {
      en:  1, es:  5, it:  7, fr:  8, pt: 10, de: 11, ca: 12, eu: 13, cs: 14,
      gl: 15, tr: 16, nl: 17, sv: 18, ru: 19, hu: 20, pl: 21, sl: 22, he: 23,
      zh: 24, sk: 25, ro: 26, el: 27, fi: 28, no: 29, da: 30, hr: 31, ja: 32,
      bg: 35, sr: 36, id: 37, ar: 38, ms: 40, ko: 42, fa: 43, bs: 44, vi: 45,
      th: 46, bn: 47
    }
    FILTER_IGNORED = "Couldn't find any subs with the specified language. " +
                     "Filter ignored"

    def subtitles_url
      "/serie/#{CGI.escape show}/#{season}/#{episode}/#{LANG_IDS[lang]}"
    end

    def subtitles_response
      response = get(subtitles_url, {}, false)
      unless Net::HTTPSuccess === response
        raise NotFoundError, "show/season/episode not found"
      end
      response
    end

    def subtitles_body
      body = subtitles_response.body
      body.strip!
      raise NotFoundError, "show/season/episode not found" if body.empty?
      if body.include? FILTER_IGNORED
        raise NotFoundError, "no subtitles available"
      end
      body
    end

    def redirected_url download_url
      header = { 'Referer' => "http://#{SITE}#{subtitles_url}" }
      response = get download_url, header, false
      case response
      when Net::HTTPSuccess
        response
      when Net::HTTPFound
        location = response['Location']
        if location == '/downloadexceeded.php'
          raise NotFoundError, "download exceeded"
        end
        URI.escape location
      end
    end

    def download_url
      link = Nokogiri(subtitles_body).css('a').find { |a|
        a[:href].start_with? '/original/' or
        a[:href].start_with? '/updated/'
      }
      raise NotFoundError, "show/season/episode not found" unless link
      download_url = link[:href]

      redirected_url download_url
    end
  end
end
