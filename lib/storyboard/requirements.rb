require 'shellwords'

module Storyboard
  class Requirements

    URLS = {
      'ffmpeg' => false,
      'ffprobe' => false,
      'gifsicle' => false,
      'convert' => false
    }

    def self.binpath
      File.expand_path(File.join(__FILE__, "..", "..", "..", "binaries"))
    end

    def self.has_path?(name)
      result = `which #{name}`
      $?.success?
    end

    def self.has?(name, param, path, version, scan_for)
      return self.has?(name, param, self.binpath, version, scan_for) if (!has_path?(name) and path.nil?)

      final_path = path.nil? ? name : File.join(path, name)

      return false if (!has_path?(final_path) and path)

      output = %x(#{Shellwords.join([final_path, param])})
      found_version = output.scan(scan_for)

      if path.nil?
        return self.has?(name, param, self.binpath, version, scan_for) if found_version.none?
        acceptable = Gem::Dependency.new(name, "~> #{version}").match?(name, found_version[0][0])
        return self.has?(name, param, self.binpath, version, scan_for) if not acceptable
        return true
      else
        return false if found_version.none?
        return Gem::Dependency.new(name, "~> #{version}").match?(name, found_version[0][0])
      end
    end

    def self.has_ffmpeg?(path=nil, version='2.1')
      self.has?("ffmpeg", "-version", nil, version, /ffmpeg version (\d.\d.\d)/)
    end

    def self.has_ffprobe?(path=nil, version='2.1')
      self.has?("ffprobe", "-version", path, version, /ffprobe version (\d.\d.\d)/)
    end

    def self.has_gifsicle?(path=nil, version='1.7')
      self.has?("gifsicle", "--version", path, version, /Gifsicle (\d.\d+)/)
    end

    def self.has_convert?(path=nil, version='6.8')
      self.has?("convert", "--version", path, version, /ImageMagick (\d.\d+)/)
    end    
  end
end