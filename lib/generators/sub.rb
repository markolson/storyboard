class Storyboard
  class Renderer
    def add_subtitle(img, subtitle)
      text = subtitle.lines.join("\n")
      txt = nil
      txtwidth = img.columns + 1
      txtsize = 29
      while(txtwidth > (img.columns * 0.8))
        txtsize -= 1
        txt = Draw.new
        txt.pointsize = txtsize
        o = txt.get_multiline_type_metrics(img, text)
        txtwidth = o.width
      end

      txt.gravity = Magick::SouthGravity
      txt.stroke_width = 1
      txt.stroke = 'transparent'
      txt.font_weight = Magick::BoldWeight

      img.annotate(txt, 0,0,-2,-2, text) {
        txt.fill = '#333333'
      }

      img.annotate(txt, 0,0,0,0, text){
        txt.fill = "#ffffff"
        txt.stroke = "#000000"
      }
      txt = nil
    end
  end
end
