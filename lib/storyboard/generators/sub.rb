require 'prawn'
class Storyboard
  class Renderer
    @@size_canvas = Prawn::Document.new
    def add_subtitle(image, subtitle, dimensions)
        offset = 0
        subtitle.lines.reverse.each_with_index {|caption,i|
          escaped = caption.gsub(/\\|'|"/) { |c| "\\#{c}" }
          font_size = 30
          text_width = dimensions[0] + 1
          while(text_width > (dimensions[0] * 0.9))
            font_size -= 1
            text_width = @@size_canvas.width_of(caption, :size => font_size)
          end

          image.combine_options do |c|
            c.font "helvetica"
            c.fill "#333333"
            c.strokewidth '1'
            c.stroke '#000000'
            c.pointsize font_size.to_s
            c.gravity "south"
            c.draw "text 0, #{offset} '#{escaped}'"
          end

          #and the shadow
          image.combine_options do |c|
            c.font "helvetica"
            c.fill "#ffffff"
            c.strokewidth '1'
            c.stroke 'transparent'
            c.pointsize font_size.to_s
            c.gravity "south"
            c.draw "text -2, #{offset-2} '#{escaped}'"
          end

          offset += (@@size_canvas.height_of(caption, :size => font_size)).ceil
        }
    end
  end
end
