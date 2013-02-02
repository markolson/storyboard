require 'prawn'
class Storyboard
  class Renderer
    @@size_canvas = Prawn::Document.new

    def write_mvg(offset, line, nudge=0)
          out = File.open('/Users/olson/Downloads/tmp.mvg', 'wt', encoding: Storyboard.current_encoding)
          p out.external_encoding
          out.print("text #{(0+nudge).to_s}, #{(offset+nudge).to_s} '")
          out.print line
          out.puts "'"
          out.close
    end
    def add_subtitle(image, subtitle, dimensions)
        offset = 0
        subtitle.lines.reverse.each_with_index {|caption,i|
          escaped = caption.gsub(Storyboard.encode_regexp(/\\|'|"/.to_s)) { |c| Storyboard.encode_string("\\#{c}") }
          escaped =Storyboard.encode_string(caption)
          font_size = 30
          text_width = dimensions[0] + 1
          while(text_width > (dimensions[0] * 0.9))
            font_size -= 1
            text_width = @@size_canvas.width_of(caption, :size => font_size)
          end

          write_mvg(offset,caption, 0)
          image.combine_options do |c|
            c.font "helvetica"
            c.fill "#333333"
            c.strokewidth '1'
            c.stroke '#000000'
            c.pointsize font_size.to_s
            c.gravity "south"
            c.draw '@/Users/olson/Downloads/tmp.mvg'
          end


          write_mvg(offset,caption, -2)
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
