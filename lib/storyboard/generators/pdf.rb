require 'prawn'
require 'mini_magick'

class Storyboard
  class PDFRenderer < Storyboard::Renderer

    attr_accessor :pdf, :storyboard, :dimensions
    def initialize(parent)
      @dimensions = []
      @storyboard = parent
    end

    def set_dimensions(w,h)
      @dimensions = [w,h]
      @pdf = Prawn::Document.new(:page_size => [w, h], :margin => 0)
    end

    def write
      @pdf.render_file "#{@storyboard.options[:write_to]}/#{@storyboard.options[:basename]}.pdf"
      LOG.info("Wrote #{@storyboard.options[:write_to]}/#{@storyboard.options[:basename]}.pdf")
    end

    def render_frame(frame_name, subtitle = nil)
      output_filename = File.join(@storyboard.options[:save_directory], "sub-#{File.basename(frame_name)}")
      image = MiniMagick::Image.open(frame_name)

      if(@dimensions.empty?)
        resize_height = (image[:height] * (@storyboard.options[:max_width].to_f/image[:width])).ceil
        set_dimensions(storyboard.options[:max_width], resize_height)
      end

      image.resize "#{@dimensions[0]}x#{@dimensions[1]}"
      image.quality("60")

      self.add_subtitle(image, subtitle, @dimensions) if subtitle
      image.format 'jpeg'
      image.write(output_filename)
      image.destroy!

      @pdf.image output_filename, :width => @dimensions[0], :height => @dimensions[1]


    end

  end
end
