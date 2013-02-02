#encoding: utf-8
class String
  def contains_cjk?
    !!(self =~ Storyboard.encode_regexp('\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}'))
  end
end
