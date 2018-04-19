module DK
  class Autofixer
    # Command
    def generate_tags_yml
      return unless @options.include?('g:tags')
      GenerateTagsYml.new(ARGV)
      exit(0)
    end

    # Generate tags.yml using DK
    class GenerateTagsYml
      def initialize(opts)
        options = {}
        options[:limit]   = opt_val('-l') || 1000
        options[:blog]    = opt_val('-b')
        options[:config]  = opt_val('--config')
        options[:source]  = opt_val('--source') || DK::PUBLISH
        # Get Posts
        dk    = DK::Client.new(options)
        posts = dk.get_posts.map { |post| DK::Post.new post  }
        posts = posts.select { |post| !post.tags.empty? }
        # Collect Tags
        @tags = []
        posts.each { |post| @tags += post.tags }
        @tstore  = YAML::Store.new("#{confile('tags.yml')}")
        # Preserve existing
        existing = restore(@tstore, :good)
        # puts "Found #{existing.size} tags." if existing
        @tags += existing if existing
        @tags  = @tags.map(&:downcase)
        @tags.uniq!
        @tags.sort!
        # Save
        # puts "Saving #{@tags.size} tags"
        store(@tstore, :good, @tags)

      end

      def opt_val(opt, default=nil)
        ARGV[ARGV.find_index(opt) + 1] rescue default
      end

      def home_file(file)
        DK::Config.home_path_file(file)
      end

      def confile(fname)
        home_file('/config_md/taf/') + fname
      end

      # Code to extract from summary
      # unless @split = opt_val('-S')
      #   puts "Please provide at least one delimiter"
      #   puts "eg. taf g:tags -S |"
      #   puts "eg. taf g:tags -S ,|/\\"
      #   exit(1)
      # end
      # posts.each do |post|
      #   comment = post.comment
      #   result = nil
      #   @split.each do |str|
      #     result ||= comment.split str
      #     result = result.map { |str2| str2.split str }.flatten
      #   end
      #   @tags += result
      # end
    end  # of GenerateTagsYml
  end # of Autofixer
end # of DK
