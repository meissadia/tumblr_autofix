module DK
  class Idable
    private

    def store(dstore, key, value)
      dstore.transaction do
        dstore[key] = value
      end
    end

    def restore(dstore, key, default=nil)
      dstore.transaction do
        dstore[key] || default
      end
    end

    def prep_user_data_files
      ex_blog_name = 'example-blog-name'
      keys = [:no_names, :last_tag, :tag_idx, :summary]
      keys.each do |key|
        unless restore(@ystore, key)
          value = []
          case key
          when :no_names
            value << 'Ignore the following blogs during processing.'
            value << ex_blog_name
          when :last_tag
            value << 'Use the last available tag for these blogs.'
            value << ex_blog_name
          when :tag_idx
            value = [
              ['Use tag #1 for these blogs.', ex_blog_name],
              ['Use tag #2 for these blogs.', ex_blog_name],
              ['Use tag #3 for these blogs.', ex_blog_name]
            ]
          when :summary
            value << 'Capitalize, add prefix and postfix to existing summary text'
            value << ex_blog_name
          end
          store(@ystore, key, value)
        end
      end
    end

  end
end
