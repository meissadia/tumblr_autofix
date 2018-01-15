module DK
  class Idable
    private
    #TODO Better output format? Use DK::Reporter?

    def show_results
      puts ' '*80 + "\r\n"
      header_simulation
      header_numbers
      unless @updated.empty?
        @updated.sort_by!{ |a| [a[0]]}
        col0 = @updated.size
        col1 = @updated.sort{|a,b| a[0].length <=> b[0].length}.last[0]
        puts "-- #{col0} posts where updated --"
        @updated.each_with_index do |row, idx|
          from, summary, link = row
          puts "#{pad(idx+1, col0, true)}. #{link} | #{pad(from,col1)} | #{summary}"
        end
        puts
      end

      unless @rest.empty?
        @rest.sort_by!{|a| [a[0]]}
        col0 = @rest.size
        col1 = @rest.sort{|a,b| a[0].length <=> b[0].length}.last[0]
        puts "-- #{col0} Posts have info, but could not be autofixed --"
        @rest.each_with_index do |row,idx|
          from, summary, tags, link = row
          summary.gsub!("\n", '\n')
          puts "#{pad(idx+1, col0, true)}. #{link} | #{pad(from,col1)} |  #{tags.take(5)} | #{summary}"
        end
        puts
      end

      puts "\nxx Errors xx\n" unless @no_trail.empty?
      unless @no_trail.empty?
        size = @no_trail.size
        puts "** #{size} Posts are missing info and require manual review **:\n"
        @no_trail.sort!{|a,b| a['id'] <=> b['id']}
        @no_trail.each_with_index{|x,idx| puts "#{pad(idx+1, size, true)}. #{link_to_edit(x)}" }
        puts
      end

      unless @no_info.empty?
        size = @no_info.size
        fname = home_file('taf_visual_review.html')
        puts "** #{size} have no info for automated processing **:\n"
        puts "** Please review posts in #{fname} **:\n"
        generate_review_webpage(@no_info, fname)
      end

    end

    def generate_review_webpage(post_info, fname)
      pg = '<html><body>'
      pg += "<p>#{post_info.size} Drafts require manual review.</p>"
      pg += "<p>Click a photo to be taken to it's edit page.</p>"
      pg += '<table>'
      post_info.each_slice(4) do |posts|
        pg += '<tr>'
        posts = posts.map{|post| DK::Post.new(post)}
        posts.each{|post| pg += post_image_code(post)}
        pg += '</tr>'
      end
      pg += '</table></body></html>'
      File.open(fname, 'w'){|f| f.puts pg}
    end

    def post_image_code(post)
      photo = post.photos.first
      res = "<td><a target='_blank' href='#{link_to_edit(post)}'><img src='#{photo.alt_sizes[3].url}'></a><br><p>#{photo.caption}</p><br><p>#{post.tags}</p></td>"
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
      puts "#{@no_info.size} posts have been ignored as 'no tags and no caption'."
      puts '_'*40
    end

  end
end
