require 'tumblr_draftking'
require 'yaml/store'
require 'sanitize'
require_relative 'autofixer/data_store'
require_relative 'autofixer/helpers'
require_relative 'autofixer/results'
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
      @clear_r  = opts.find_index('--clear-rest')
      @dk       = DK::Client.new(dk_opts)
      `cp summary.yml ~/taf_summary.yml`
      `cp data.yml.bak ~/taf_data.yml`
      @ystore   = YAML::Store.new(home_file('taf_data.yml'))
      @sstore   = YAML::Store.new(home_file('taf_summary.yml'))
      @no_trail, @updated, @rest = [], [], []
      @processed = 0
      @total = 0
      @no_info   = []

      prep_user_data_files
      @last_tag = restore(@ystore, :last_tag)
      @tag_idx  = restore(@ystore, :tag_idx)
      @summary  = restore(@ystore, :summary)
      @ignore   = restore(@ystore, :ignore)

      autofixer(get_informative_posts)
      show_results
    end

    private

    def show_version(opts)
      return unless opts.include?('-v')
      puts "\ntumblr_autofixer v0.0.1"
      puts
      exit
    end

    def get_informative_posts
      drafts = @dk.get_posts
      @total = drafts.size
      drafts.select do |draft|
        (@processed += 1)     && next if     post_processed?(draft)
        (@no_info   << draft) && next unless (post_has_info?(draft) || post_has_trail?(draft))
        (@no_trail  << draft) && next unless post_has_trail?(draft)
        true
      end
    end

    # Post already has prefix?
    def post_processed?(post)
      summary = post['summary'].chomp.strip
      user_c  = Sanitize.fragment(post['reblog']['comment']).strip
      user_c.start_with?(@prefix) || summary.start_with?(@prefix)
    end

    # Post has a summary or tags?
    def post_has_info?(post)
      summary = post['summary'].chomp.strip
      tags    = post['tags']
      !summary.empty? || !tags.empty?
    end

    # Do we know where it was reblogged from?
    def post_has_trail?(post)
      !post['trail'].empty?
    end


    def autofixer(posts)
      posts.each_with_index do |post, idx|
        c_text = post['summary']
        tags   = post['tags']
        from   = post['trail'].first['blog']['name']

        next if @ignore.include?(from)
        next if fix_from_tag(post, idx, from)

        if commands = restore(@sstore, from.to_sym) # has custom processing defined
          new_comment = special_summary(c_text, from, commands)
          success = update_post_comment(post, new_comment)
          @updated << [from, new_comment, link_to_edit(post)] if success
        elsif @summary.include?(from)
          new_comment = special_summary(c_text, from, [])
          success = update_post_comment(post, new_comment)
          @updated << [from, new_comment, link_to_edit(post)] if success
        elsif @last_tag.include?(from)
          new_comment = autofix(tags.last, from)
          next if new_comment.eql?(ERROR_STRING)
          success = update_post_comment(post, new_comment)
          @updated << [from, new_comment, link_to_edit(post)] if success
        else
          if @clear_r # add base prefix to skip these posts in future runs
            success = update_post_comment(post, @prefix)
            @updated << [from, @prefix, link_to_edit(post)] if success
          elsif
            short_summary = c_text.length > C_LEN ? c_text[0,C_LEN] + '...' : c_text
            @rest << [from, short_summary, tags, link_to_edit(post)]
          end
        end
      end
    end

    def fix_from_tag(post, idx, from)
      @tag_idx.each_with_index do |names, idx|
        next unless names.include?(from)
        new_comment = autofix(post['tags'][idx], from)
        return false if new_comment.eql?(ERROR_STRING)
        success = update_post_comment(post, new_comment)
        @updated << [from, new_comment, link_to_edit(post)] if success
        return true
      end
      false
    end

    def autofix(tag, from)
      return ERROR_STRING if tag.nil?
      prefix(capitalize(tag))
    end

    def update_post_comment(post, comment)
      res = DK::Post.new(post)
      res.replace_comment_with(comment)
      res.save(client: @dk.client, simulate: @dk.simulate)
    end

    def special_summary(summary, from, commands)
      return if summary.nil? || from.nil?
      lines = summary.split("\n")
      res   = summary.downcase
      b     = binding
      commands.each{ |x| eval(x, b) }
      prefix(capitalize(res))
    end

  end # end of DK::Idable
end # end of DK

if __FILE__ == $0
  DK::Idable.new(ARGV)
end
