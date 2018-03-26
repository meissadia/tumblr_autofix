require 'tumblr_draftking'
require 'yaml/store'
require 'sanitize'
require 'fileutils'
Dir[File.join(__dir__, 'autofixer', '**', '*.rb')].each {|file| require file }
# require 'pry'

module DK
  class Idable
    C_LEN = 25
    ERROR_STRING = '**'
    def initialize(opts)
      check_for_command(ARGV, opts)
      extract_opts(opts)

      @config_dir = home_file('/config_md/taf/')
      @dk = DK::Client.new(dk_opts)

      # Ensure my latest config files are in place.
      `cp data.yml.bak #{confile('data.yml')}`   if File.exist?('data.yml.bak')
      `cp summary.yml #{confile('summary.yml')}` if File.exist?('summary.yml')

      read_configuration
      @already_processed, @need_review, @updated = [], [], []

      autofixer(get_informative_posts)
      @need_review = clear(@need_review) if @clear
      show_results
    end

    private

    def read_configuration
      # Ensure directory structure exists
      FileUtils::makedirs @config_dir unless Dir.exist?(@config_dir)

      # Ensure configuration files are present
      @ystore   = YAML::Store.new("#{confile('data.yml')}")
      @sstore   = YAML::Store.new("#{confile('summary.yml')}")
      prep_user_data_files

      # Cache config data
      @last_tag = restore(@ystore, :last_tag)
      @tag_idx  = restore(@ystore, :tag_idx)
      @summary  = restore(@ystore, :summary)
      @ignore   = restore(@ystore, :ignore)
    end

    def check_for_command(args, opts)
      show_help(args, opts)
      show_version(opts)
      open_results(args)
    end

    def confile(fname)
      @config_dir + fname
    end

    def extract_opts(opts)
      @simulate = opts.include?('-s')
      @limit    = opts[opts.find_index('-l') + 1].to_i rescue nil
      @spliter  = opts[opts.find_index('-S') + 1] rescue ' '
      @prefix   = opts[opts.find_index('-p') + 1] rescue ''
      @postfix  = opts[opts.find_index('-P') + 1] rescue ''
      @showres  = opts.find_index('--show')
      @clear    = opts.find_index('--clear')
    end

    def get_informative_posts
      drafts = @dk.get_posts.map{|post| DK::Post.new(post)}
      @total = drafts.size
      drafts.select do |draft|
        ((@already_processed << draft) && next) if post_already_processed?(draft)
        ((@need_review << draft) && next) unless post_has_info?(draft)
        ((@need_review << draft) && next) unless post_has_trail?(draft)
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
          next # Successfully used a tag-index to process post
        elsif commands = restore(@sstore, trail_name.to_sym)
          # Has custom processing of post.summary data defined
          new_comment = special_summary(post_summary, trail_name, commands)
        elsif @summary.include?(trail_name)
          # Use default processing of post.summary data
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
        (success ? @updated : @need_review) << post
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
      error = []
      posts.each do |post|
        success = update_post_comment(post, @prefix)
        (success ? @updated : error) << post
      end
      error
    end

  end # end of DK::Idable
end # end of DK

if __FILE__ == $0
  DK::Idable.new(ARGV)
end
