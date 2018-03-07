module DK
  class Idable
    private
    #TODO Better output format? Use DK::Reporter?

    def show_results
      puts ' '*80 + "\r\n"
      header_simulation
      header_numbers

      if @clear_r
        @need_review.each do |post|
          success = update_post_comment(post, @prefix)
          @updated << post if success
        end
        @need_review = []
      end

      unless @updated.empty?
        # @updated.sort_by!{ |a| [a[0]]}
        @updated.sort_by!{|a| [a.from.length, a.from, a.id]}
        # @updated = @updated.uniq
        col0 = @updated.size
        col1 = @updated.last.from
        puts "-- #{col0} posts where updated --"
        @updated.each_with_index do |post, idx|
          summary = post.comment || '<N/S>' rescue '<N/S>'
          tags   = post.tags || ['<N/T>'] rescue ['<N/T>']
          from   = post.trail.first.blog.name || '<N/F>' rescue '<N/F>'
          link   = link_to_edit(post) || '<N/L>' rescue '<N/L>'

          puts "#{pad(idx+1, col0, true)}. #{link} | #{pad(from,col1)} | #{summary}"
        end

        size = @updated.size
        fname = home_file('taf_updated.html')
        puts "** #{size} have been updated. **:\n"
        puts "** Please review posts in #{fname} **:\n"
        generate_review_webpage(@updated, fname)
        puts
      end


      unless @rest.empty?
        @rest.sort_by!{|a| [a.id]}
        col0 = @rest.size
        col1 = @rest.last.id
        puts "-- #{col0} Posts have info, but could not be autofixed --"
        @rest.each_with_index do |row, idx|
          summary = row.comment || '<N/S>' rescue '<N/S>'
          tags    = row.tags    || ['<N/T>'] rescue ['<N/T>']
          from    = row.trail.first.blog.name || '<N/F>' rescue '<N/F>'
          link    = link_to_edit(post) || '<N/L>' rescue '<N/L>'
          summary.gsub!("\n", '\n')
          puts "#{pad(idx+1, col0, true)}. #{link} | #{pad(from,col1)} |  #{tags.take(5)} | #{summary}"
        end
        puts
      end

    end

    def generate_review_webpage(post_info, fname)
      pg = '<html><body>'
      pg += "<p>#{post_info.size} Drafts require manual review.</p>"
      pg += "<p>Click a photo to be taken to it's edit page.</p>"
      pg += '<table>'
      post_info.each_slice(4) do |posts|
        pg += '<tr>'
        posts.each{|post| pg += post_image_code(post)}
        pg += '</tr>'
      end
      pg += '</table></body></html>'
      File.open(fname, 'w'){|f| f.puts pg}
    end

    def post_image_code(post)
      photo = post.photos.first
      res  = "<td><a target='_blank' href='#{link_to_edit(post)}'>"
      res += "<img src='#{photo.alt_sizes[3].url}'></a><br>"
      res += "<p>#{post.comment}</p><br><p>#{post.tags}</p></td>"
    end

    def header_simulation
      if @simulate
        puts '*'*40
        puts '*'*14 + ' SIMULATION ' + '*'*14
        puts '*'*40
        puts
      end
    end

    def header_numbers
      puts '_'*40
      puts "#{@total} Drafts were retrieved."
      puts "#{@processed} posts have been ignored as 'already processed'."
      puts "#{@need_review.size} posts have been ignored as 'no tags and no caption'."
      puts '_'*40
    end

  end
end
