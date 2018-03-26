require 'tumblr_draftking'
require 'yaml/store'
require 'sanitize'
require 'pry'
require_relative 'autofixer/data_store'
require_relative 'autofixer/helpers'
require_relative 'autofixer/results'
require 'fileutils'
# require 'pry'

module DK
  class Idable
    C_LEN = 25
    ERROR_STRING = '**'
    def initialize(opts)
      show_version(opts)
      @simulate = opts.include?('-s')
      @limit    = opts[opts.find_index('-l') + 1].to_i rescue nil
      @spliter  = opts[opts.find_index('-S') + 1] rescue ' '
      @prefix   = opts[opts.find_index('-p') + 1] rescue nil
      @postfix  = opts[opts.find_index('-P') + 1] rescue nil
      @clear    = opts.find_index('--clear')
      @dk       = DK::Client.new(dk_opts)
      `cp data.yml.bak ~/config_md/taf/data.yml`   if File.exist?('data.yml.bak')
      `cp summary.yml ~/config_md/taf/summary.yml` if File.exist?('summary.yml')

      # Ensure directory structure exists
      c_dir = home_file('/config_md/taf/')
      FileUtils::makedirs c_dir unless Dir.exist?(c_dir)
      @ystore   = YAML::Store.new("#{c_dir}data.yml")
      @sstore   = YAML::Store.new("#{c_dir}summary.yml")

      @already_processed = []
      @need_review = []
      @updated = []
      @error = []

      prep_user_data_files
      @last_tag = restore(@ystore, :last_tag)
      @tag_idx  = restore(@ystore, :tag_idx)
      @summary  = restore(@ystore, :summary)
      @ignore   = restore(@ystore, :ignore)

      autofixer(get_informative_posts)
      if @clear
        clear(@need_review)
        @need_review = @error
      end
      show_results
    end

    private

    def show_version(opts)
      return unless opts.include?('-v')
      puts "\ntumblr_autofixer v0.0.3"
      puts
      exit
    end

    def get_informative_posts
      drafts = @dk.get_posts.map{|post| DK::Post.new(post)}
      @total = drafts.size
      drafts.select do |draft|
        ((@already_processed << draft) && next) if post_already_processed?(draft)
        ((@need_review << draft)  && next) unless post_has_info?(draft)
        ((@need_review << draft)  && next) unless post_has_trail?(draft)
        true
      end
    end

    # Post already has prefix?
    def post_already_processed?(post)
      summary = post.summary.chomp.strip
      user_c  = Sanitize.fragment(post.comment).strip
      user_c.start_with?(@prefix) || summary.start_with?(@prefix)
    end

    # Post has a summary or tags?
    def post_has_info?(post)
      summary = post.summary.chomp.strip
      !summary.empty? || !post.tags.empty?
    end

    # Do we know where it was reblogged from?
    def post_has_trail?(post)
      !post.trail.empty?
    end


    def autofixer(posts)
      posts.each_with_index do |post, idx|
        tags = post.tags
        trail_name   = post.trail.first.blog.name
        post_summary = post.summary

        ((@need_review << post) && next) if @ignore.include?(trail_name)
        if fix_from_tag(post, trail_name)
          # Successfully used a tag-index to process post
          next
        elsif commands = restore(@sstore, trail_name.to_sym)
          # Has custom processing defined
          new_comment = special_summary(post_summary, trail_name, commands)
        elsif @summary.include?(trail_name)
          # Create comment from post.summary
          new_comment = special_summary(post_summary, trail_name, [])
        elsif @last_tag.include?(trail_name)
          # Use the last available post.tags
          new_comment = autofix(tags.last, trail_name)
        else
          # Don't know what to do with it.
          new_comment = ERROR_STRING
        end

        ((@need_review << post) && next) if new_comment.eql?(ERROR_STRING)
        
        success = update_post_comment(post, new_comment)
        (success ? @updated : @needs_review) << post
      end
    end

    def fix_from_tag(post, blog_name)
      @tag_idx.each_with_index do |names, idx|
        next unless names.include?(blog_name)
        new_comment = autofix(post.tags[idx])
        if new_comment.eql?(ERROR_STRING)
          # No tag at the expected tag-index
          @need_review << post
          return false
        end
        success = update_post_comment(post, new_comment)
        (success ? @updated : @need_review) << post
        return true
      end
      false
    end

    def autofix(tag, from='')
      return ERROR_STRING if tag.nil?
      prefix(capitalize(tag))
    end

    def update_post_comment(post, comment)
      post.replace_comment_with(comment)
      post.save(client: @dk.client, simulate: @dk.simulate)
    end

    def special_summary(summary, from, commands)
      return '' if summary.nil? || from.nil?
      lines = summary.split("\n")
      res   = summary.downcase
      b     = binding
      commands.each{ |x| eval(x, b) }
      prefix(capitalize(res))
    end

    def clear(posts)
      posts.each do |post|
        success = update_post_comment(post, @prefix)
        (success ? @updated : @error) << post
      end
    end

  end # end of DK::Idable
end # end of DK

if __FILE__ == $0
  DK::Idable.new(ARGV)
end
