require 'prawn'
class Storyboard
  class Renderer
    @@size_canvas = Prawn::Document.new

    def write_mvg(offset, line, nudge=0)
      out = File.open('/Users/olson/Downloads/tmp.mvg', 'wt', encoding: 'UTF-8')
      out.print("text #{(0+nudge).to_s}, #{(offset+nudge).to_s} '")
      out.print line
      out.print "'"
      out.close
    end

    def add_subtitle(image, subtitle, dimensions)
      offset = 0
      subtitle.lines.reverse.each_with_index {|caption,i|
        escaped = caption.gsub('\'') {|s| "\\#{s}" }
        font_size = 30
        text_width = dimensions[0] + 1
        while(text_width > (dimensions[0] * 0.9))
          font_size -= 1
          text_width = @@size_canvas.width_of(caption.encode!("utf-8"), :size => font_size)
        end

        font = Storyboard.needs_KFhimaji ? "#{Storyboard.path}/fonts/KFhimaji.otf" : "Helvetica"

        write_mvg(offset,escaped, 0)
        image.combine_options do |c|
          c.font font
          c.fill "#333333"
          c.strokewidth '1'
          c.stroke '#000000'
          c.pointsize font_size.to_s
          c.gravity "south"
          c.draw '@/Users/olson/Downloads/tmp.mvg'
        end


        write_mvg(offset,escaped, -2)
        #and the shadow
        image.combine_options do |c|
          c.font font
          c.fill "#ffffff"
          c.strokewidth '1'
          c.stroke 'transparent'
          c.pointsize font_size.to_s
          c.gravity "south"
          c.draw '@/Users/olson/Downloads/tmp.mvg'
        end

        offset += (@@size_canvas.height_of(caption.encode!("utf-8"), :size => font_size)).ceil
      }
    end
  end
end
