module DK
  class Idable
    private

    def bfrom(post)
      post.trail.first.blog.name rescue '-no trail-'
    end

    def show_results
      cli_header

      fname1 = confile('already_processed.html')
      fname2 = confile('need_review.html')
      fname3 = confile('updated.html')

      @file_index = [
        ["Needs Review (#{@need_review.size})", fname2],
        ["Updated (#{@updated.size})", fname3],
        ["Already Processed (#{@already_processed.size})", fname1]
      ]

      msg1  = "(#{@already_processed.size}) Drafts are ready to be queued."
      msg2  = "(#{@need_review.size}) Drafts need visual review."
      msg3  = "(#{@updated.size}) Drafts were Autofixed."


      # Already Processed
      @already_processed.sort_by!{ |x| x.id }
      generate_review_webpage(@already_processed, fname1, msg1)

      # Need Review
      @need_review.sort_by! do |x|
        bname = bfrom(x)
        [bname, x.id]
      end
      generate_review_webpage(@need_review, fname2, msg2)

      # Updated
      @updated.sort_by!{ |x| bfrom(x)}
      generate_review_webpage(@updated, fname3, msg3)

      puts
      puts
      `open #{@file_index.first.last}` if @showres
    end

    def generate_review_webpage(post_info, fname, msg1='')
      page = "<html><head>#{style}</head><body>"
      page += page_nav
      page += '<table>'
      page += '<caption>'
      page += "<p>***** SIMULATION RUN *****</p>" if @simulate
      page += "<p>#{msg1}</p>"
      page += "<p>Click a photo to be taken to it's edit page.</p>"
      page += '</caption>'
      page += table_header
      post_info.each_slice(1) do |posts|
        page += '<tr>'
        posts.each{|post| page += post_image_code(post)}
        page += '</tr>'
      end
      page += '</table>'
      page += "</body></html>"

      # Create directory structure and file if it doesn't exist
      File.open(fname, 'w'){|f| f.puts page}
      puts "** Updated file: #{fname} **:\n"
    end

    def post_image_code(post)
      # Alt Sizes (0 - 6) Large to Small
      count = post.photos.size
      photo = count > 0 ? post.photos.first.alt_sizes[4].url : image_missing
      res  = "<td><a target='_blank' href='#{link_to_edit(post)}'>"
      res += "<img src='#{photo}'>#{'  (' + count.to_s + ')' if count > 1}</a></td>"
      res += "<td><p>#{bfrom(post)}</p></td>"
      res += "<td><p>#{post.comment.empty? ? '-no comment-' : post.comment}</p></td>"
      res += "<td><p>#{post.tags.empty? ? '-no tags-' : post.tags.join(', ')}</p></td>"
    end

    def cli_header
      puts ' '*80 + "\r\n"  # Clear any lingering text
      if @simulate
        puts '*'*40
        puts '*'*14 + ' SIMULATION ' + '*'*14
        puts '*'*40
        puts
      end
      puts '_'*40
      puts
      puts "#{@total} drafts were retrieved."
      puts "#{pad(@updated.size, @total, 1)} drafts were Autofixed."
      puts "#{pad(@already_processed.size, @total, 1)} drafts were marked 'already processed'."
      puts "#{pad(@need_review.size, @total, 1)} drafts require visual review."
      puts '_'*40
      puts
    end

    def page_nav
      res = '<nav><ul>'
      @file_index.each do |text, file|
        res += %(<li><a href='#{file}'>#{text}</a></li>)
      end
      res += '</ul></nav>'
    end

    def table_header
      res = '<thead><tr>'
      res += '<th>Photo</th>'
      res += '<th>Source</th>'
      res += '<th>Caption</th>'
      res += '<th>Tags</th>'
      res += '</tr></thead>'
    end

    def style
      %q(
        <style>
          table, tr, nav { width: 100%; text-align: center; vertical-align: middle; }
          th { background-color: grey; border: 1px solid black; color: white; }
          td { width: 25%; border: 1px solid gainsboro; }
          table caption { background-color: rgb(43, 171, 171); }
          nav { height: 100px; background-color: black; color: white; }
          nav ul li { display: inline-block; width: 30%}
          nav ul li a { display: inline-block; width: 100%; }
          nav ul li:hover { background-color: rgb(43, 171, 171); }
          a, a:visited { color: white; vertical-align: middle; line-height: 100px; }
        </style>
      )
    end

    def image_missing
      'https://us-east-1.tchyn.io/snopes-production/uploads/2018/03/rating-false.png'
    end

  end
end
