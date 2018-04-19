module DK
  class Autofixer
    ERROR     = '**'
    POSTS     = '/Users/meis/coding/rails/autofixer/db/test.posts'
    CONFIGDIR = '/config_md/taf/'
    INFO = 'info'
    WARN = 'warning'
    ERRO = 'error'

    attr_accessor :dk                           # DraftKing for Tumblr
    attr_accessor :simulate, :limit             # DraftKing Settings
    attr_accessor :config_dir                   # Autofixer Required Structure
    attr_accessor :last_tag, :summary, :tag_idx # Autofixer Tagging Config
    attr_accessor :spliter, :prefix, :postfix   # Autofixer Tagging Options
    attr_accessor :clear, :use_test, :reprocess # Autofixer Processing Options
    attr_accessor :show_results, :hide_pics     # Autofixer Result Options
    attr_accessor :processed, :review, :updated # Autofixer Results

    def initialize(opts = {})
      set_instance_vars(opts)
      installed_test_configuration?
      read_configuration
    end

    # Automated Processing
    def run
      perform_command? # Commands will exit(#)
      process(get_filtered_posts)
      @review = apply_tag_matcher_to(@review)
      @review = clear(@review)
      show_results
    end

    # Execute Command
    def perform_command?
      show_help
      show_config
      show_version
      open_results
      generate_tags_yml
      if @options.first && !@options.first[0].eql?('-')
        puts "\nCommand '#{@options.first}' not found.\n\n"
        exit(1)
      end
    end

    # Load data and filter out processed or seemingly unprocessible posts
    def get_filtered_posts
      drafts = @usetestdata ? load_test_data : @dk.get_posts
      @total = drafts.size
      drafts.map do |draft|
        draft = DK::Post.new draft
        next if filter_processed? draft
        next if filter_by_info?   draft
        next if filter_by_trail?  draft
        draft
      end.compact
    end

    # Construct new post comments based on available configurations
    def process(posts)
      posts.each_with_index do |post, idx|
        tags    = post.tags
        blog    = post.trail.first.blog.name
        summary = post.summary

        next if ignore? blog, post
        # Scan for configured tag-index
        comment = use_tag_index blog, post
        # Use coded configuration
        comment ||= use_commands blog, summary
        # Use full summary text
        comment ||= use_summary blog, summary
        # Use last tag
        comment ||= use_tag_index blog, post, @last_tag.include?(blog)
        # No automated processing
        comment ||= ERROR

        success = update_post_comment(post, comment)
        (success ? @updated : @review) << post
      end
    end

    # Contruct a comment using any whitelisted tags
    # return: [String] Normalized Comment
    def tag_matcher(tags)
      return ERROR if tags.empty?
      joiner = ' | '
      matches = tags.select{ |tag| @gtags.include? tag.downcase }
      return ERROR if matches.empty?
      new_comment = matches.join(joiner)
      normalize(new_comment)
    end

    # Mass processing based on whitelisted tags
    # return: [Array] Unmatched Posts
    def apply_tag_matcher_to(posts)
      return posts unless @gtags
      return posts if @gtags.empty?
      not_matched = []
      while (post = posts.shift)
        next if post.tags.empty?
        new_comment = tag_matcher(post.tags)
        if new_comment.eql?(ERROR)
          not_matched << post
          next
        end
        success = update_post_comment(post, new_comment)
        (success ? @updated : not_matched) << post
      end
      not_matched
    end

    private

    # **************************************************************************
    # Processing Methods
    # **************************************************************************
    # Use the user coded processing for this blog
    def use_commands(blog, summary)
      commands = restore(@sstore, blog.to_sym)
      special_summary(summary, blog, commands)
    end

    # Normalize and use the full summary text
    def use_summary(blog, summary)
      return nil unless @summary.include?(blog)
      special_summary(summary, blog, [])
    end

    # Use the tag at the configured index, if available
    # return: [boolean] Success?
    def use_tag_index(blog_name, post, last=nil)
      return normalize post.tags.last if last
      @tag_idx.each_with_index do |names, idx|
        next unless names.include?(blog_name)
        return normalize(post.tags[idx])
      end
      nil
    end

    def update_post_comment(post, comment)
      return false if comment.eql? ERROR
      post.replace_comment_with(comment)
      post.save(client: @dk.client, simulate: @dk.simulate)
    end

    def special_summary(summary, from, commands)
      return nil if summary.nil? || from.nil?
      return nil unless commands
      lines = summary.split("\n")
      res   = summary.downcase
      b     = binding
      commands.each{ |x| eval(x, b) }
      normalize(res)
    end

    def clear(posts)
      return posts unless @clear
      error = []
      posts.each do |post|
        success = update_post_comment(post, @prefix)
        (success ? @updated : error) << post
      end
      error
    end

    def affix(s)
      result = ''
      result += "#{@prefix}" if @prefix
      result += "#{' ' + @spliter + ' '}"
      result += "#{s}"
      if @postfix
        result += "#{' ' + @spliter + ' '}"
        result += "#{@postfix}"
      end
      result
    end

    def log(type, msg)
      @messages << "#{type.capitalize}: #{msg}"
    end

    # **************************************************************************
    # Filtration Methods
    # **************************************************************************
    def filter_processed?(draft)
      if draft.processed?(skip: @reprocess, prefix: @prefix)
        @processed << draft
        return true
      end
      false
    end

    def filter_by_info?(draft)
      unless draft.has_info?
        @review << draft
        return true
      end
      false
    end

    def filter_by_trail?(draft)
      unless draft.has_trail?
        @review << draft
        return true
      end
      false
    end

    def ignore?(blog, post)
      return false unless @ignore.include? blog
      @review << post
      true
    end

    # **************************************************************************
    # Configuration Methods
    # **************************************************************************
    def dk_opts
      { simulate: @simulate, limit: @limit }
    end

    def home_file(file)
      DK::Config.home_path_file(file)
    end

    def confile(fname)
      @config_dir + fname
    end

    def set_instance_vars(opts)
      @options  = opts
      @simulate = @options.include?('-s')
      @limit    = @options[@options.find_index('-l') + 1].to_i rescue nil
      @spliter  = @options[@options.find_index('-S') + 1] rescue ' '
      @prefix   = @options[@options.find_index('-p') + 1] rescue nil
      @postfix  = @options[@options.find_index('-P') + 1] rescue nil
      @clear    = @options.find_index('--clear')
      @reprocess    = @options.find_index('--reprocess')
      @hide_pics    = @options.find_index('--no-pics')
      @usetestdata  = @options.find_index('--test')
      @show_results = @options.find_index('--show')
      @config_dir   = home_file(CONFIGDIR)
      @dk = DK::Client.new(dk_opts)
      @messages  = []
      @processed = []
      @updated   = []
      @review    = []
    end

    def read_configuration
      # Ensure directory structure exists
      FileUtils::makedirs @config_dir unless Dir.exist?(@config_dir)

      # Ensure configuration files are present
      @ystore   = YAML::Store.new("#{confile('data.yml')}")
      @sstore   = YAML::Store.new("#{confile('summary.yml')}")
      @tstore   = YAML::Store.new("#{confile('tags.yml')}")
      prep_user_data_files

      # Cache config data
      @last_tag = restore(@ystore, :last_tag)
      @tag_idx  = restore(@ystore, :tag_idx)
      @summary  = restore(@ystore, :summary)
      @ignore   = restore(@ystore, :ignore)
      @gtags    = restore(@tstore, :good)
    end

    def load_test_data
      return eval(File.open(POSTS, 'r').read) if File.exist? POSTS
      log INFO, "Saved post data to #{POSTS}"
      posts = @dk.get_posts
      File.open(POSTS, 'w') { |f| f.write posts }
      posts
    end

    def installed_test_configuration?(result=nil)
      data_yml    = home_file('/coding/ruby/tumblr_autofixer/data.yml.bak')
      summary_yml = home_file('/coding/ruby/tumblr_autofixer/summary.yml')
      if File.exist? data_yml
        `cp #{data_yml} #{confile('data.yml')}`
        result = true
      end
      if File.exist? summary_yml
        `cp #{summary_yml} #{confile('summary.yml')}`
        result = true
      end
      result
    end

  end # end of DK::Autofixer
end # end of DK
