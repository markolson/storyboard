require 'path'
require 'zip/zip'
require 'mime/types'

Path.require_tree 'suby', except: %w[downloader/]

module Suby
  NotFoundError = Class.new StandardError
  DownloaderError = Class.new StandardError

  SUB_EXTENSIONS = %w[srt sub]
  TMPDIR = Path.tmpdir
  TEMP_ARCHIVE = TMPDIR / 'archive'
  TEMP_SUBTITLES = TMPDIR / 'subtitles'

  class << self
    include Interface

    def download_subtitles(files, options = {})
      Zip.options[:on_exists_proc] = options[:force]
      files.each { |file|
        file = Path(file)
        if file.dir?
          download_subtitles(file.children, options)
        elsif SUB_EXTENSIONS.include?(file.ext)
          # ignore already downloaded subtitles
        elsif !options[:force] and SUB_EXTENSIONS.any? { |ext| f = file.sub_ext(ext) and f.exist? and !f.empty? }
          puts "Skipping: #{file}"
        elsif !file.exist? or video?(file)
          download_subtitles_for_file(file, options)
        end
      }
    ensure
      TMPDIR.rm_rf
    end

    def video?(file)
      MIME::Types.type_for(file.path).any? { |type| type.media_type == "video" }
    end

    def download_subtitles_for_file(file, options)
      begin
        puts file
        success = Downloader::DOWNLOADERS.find { |downloader_class|
          try_downloader(downloader_class.new(file, options[:lang]))
        }
        error "\nNo downloader could find subtitles for #{file}" unless success
      rescue
        error "\nThe download of the subtitles failed for #{file}:"
        error "#{$!.class}: #{$!.message}"
        $stderr.puts $!.backtrace
      end
    end

    def try_downloader(downloader)
      return false unless downloader.support_video_type?
      begin
        print "  #{downloader.to_s.ljust(20)}"
        downloader.download
      rescue Suby::NotFoundError => error
        failure "Failed: #{error.message}"
        false
      rescue Suby::DownloaderError => error
        error "Error: #{error.message}"
        false
      else
        success downloader.success_message
        true
      end
    end

    def extract_sub_from_archive(archive, format, file)
      case format
      when :zip
        Zip::ZipFile.open(archive.to_s) { |zip|
          sub = zip.entries.find { |entry|
            entry.to_s =~ /\.#{Regexp.union SUB_EXTENSIONS}$/
          }
          raise "no subtitles in #{archive}" unless sub
          sub.extract(file.to_s)
        }
      else
        raise "unknown archive type (#{archive})"
      end
    ensure
      archive.unlink if archive.exist?
    end
  end
end
