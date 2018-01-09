module DK
  class Idable
    private

    def dk_opts
      { simulate: @simulate, limit: @limit }
    end

    def capitalize(s)
      return if s.nil?
      res = s.gsub(/\d/,'').split(' ').map(&:strip).map(&:capitalize)
      return res[0] if res.size < 2
      res.join(' ')
    end

    def prefix(s)
      "#{@prefix}#{' ' + @spliter + ' ' if @spliter}#{s}#{@postfix}"
    end

    def link_to_edit(post)
      id = post.id rescue post['id']
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

    def home_file(file)
      DK::Config.home_path_file(file)
    end

  end
end
