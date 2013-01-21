class Object
  def command?(name)
    `which #{name}`
    $?.success?
  end
end

class Storyboard
  def self.mkvtools_installed?
    command?("mkvextract") && command?("mkvmerge")
  end

  def self.mp4box_insatlled?
    command?("MP4Box")
  end

  def self.magick_installed?
    command?("mogrify")
  end

  def self.ffprobe_installed?
    good = command?("ffprobe")
    if good
      version = `ffprobe -version`.scan(/version ([\d\.]+)\n/)
      if version.empty?
        good = false
      else
        float_version = version.first[0].to_f
        good = float_version >= 1.1
      end
    end
    return good
  end
end
