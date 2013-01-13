require 'prawn'

require 'rmagick'
include Magick

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
      @pdf.render_file "#{@storyboard.options[:write_to]}/out.pdf"
      LOG.info("Wrote #{@storyboard.options[:write_to]}/out.pdf")
    end

    def render_frame(frame_name, subtitle = nil)
      image_output = File.join(@storyboard.options[:save_directory], "sub-#{File.basename(frame_name)}")
      img = ImageList.new(frame_name)

      if(@dimensions.empty?)
        resize_height = (img.rows * (@storyboard.options[:max_width].to_f/img.columns)).ceil
        set_dimensions(storyboard.options[:max_width], resize_height)
      end

      img.resize_to_fit!(@dimensions[0], @dimensions[1])

      self.add_subtitle(img, subtitle) if subtitle

      img.format = 'jpeg'
      img.write(image_output) { self.quality = 50 }
      img.destroy!
      #p "#{@dimensions[0]}x#{@dimensions[1]}"
      @pdf.image image_output, :width => @dimensions[0], :height => @dimensions[1]
    end

  end
end
