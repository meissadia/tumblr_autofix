module DK
 class Autofixer
    def normalize(tag, from='')
      return ERROR if tag.nil?
      affix(capitalize(tag))
    end

    def capitalize(s)
      return if s.nil?
      res = s.gsub(/\d/,'').split(' ').map(&:strip).map(&:capitalize)
      return res[0] if res.size < 2
      res.join(' ')
    end

    def link_to_edit(id)
      "https://www.tumblr.com/edit/#{id}"
    end

    def pad(value, reference, prefix=nil)
      s = value.to_s
      r = reference.to_s.length
      if prefix
        s = ' ' + s while (s.length < r)
      else
        s += ' ' while (s.length < r)
      end
      s
    end

  end
end
