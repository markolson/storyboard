require 'prawn'

require 'rmagick'
include Magick

class Storyboard
  class PDFRenderer
    def self.render_frame(storyboard, frame)

      save_directory = File.join(storyboard.options[:write_to], 'raw_frames')
      storyboard.capture_points.each_with_index {|x,i|
        #p x.value
        image_name = File.join(save_directory, "%04d.jpg" % [i])
        img = ImageList.new(image_name)
        resize_height = (img.rows * (storyboard.options[:max_width].to_f/img.columns)).ceil
        img = img.resize_to_fit(storyboard.options[:max_width], resize_height)
        #p "========================================"
        #p img
        txt = nil
        # Find any subtitles that go with this frame.
        storyboard.subtitles.pages.each {|page|
          if txt.nil? && x.value >=  page.start_time.value and x.value <= page.end_time.value
            txtwidth = img.columns + 1
            txtsize = 29
            while(txtwidth > (img.columns * 0.8))
              txtsize -= 1
              txt = Draw.new
              txt.pointsize = txtsize
              o = txt.get_multiline_type_metrics(img, page.lines.join("\n"))
              txtwidth = o.width
              #p o
            end
            txt.gravity = Magick::SouthGravity
            txt.stroke_width = 1
            txt.stroke = 'transparent'
            txt.font_weight = Magick::BoldWeight

            img.annotate(txt, 0,0,-2,-2, page.lines.join("\n")) {
              txt.fill = '#333333'
            }

            img.annotate(txt, 0,0,0,0, page.lines.join("\n")){
              txt.fill = "#ffffff"
              txt.stroke = "#000000"
              #txt.font_style = Magick::ItalicStyle
            }
            #p page.lines.join(" | ")
            #.gsub(%r{</?[^>]+?>}, '')
            #p "Got subtitle for frame #{i}; #{x.value}, #{page.start_time.value}, #{page.end_time.value}"
          end

        } #end subtitle loop
        if txt.nil?
          #p "OH NO #{i}"
          #exit
        end
        img.format = 'jpeg'
        img.write(File.join(save_directory, "sub-%04d.jpg" % [i])) { self.quality = 50 }

      } # end storyboard loop
    end

    def add_subtitle(frame)

    end
  end
end
=begin
image_path = ARGV[0]


p image_path

pdf = Prawn::Document.new(:page_size => [640, 480], :margin => 0)
  Dir["#{image_path}/*.jpg"].each {|i|
    p i
    pdf.image i, :height => 480, :width => 640
  }

 pdf.render_file "#{image_path}.pdf"
=end
