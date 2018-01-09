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
      example = 'example-blog-name'
      keys = [:no_names, :last_tag, :tag_idx, :summary]
      keys.each do |key|
        unless restore(@ystore, key)
          value = []
          case key
          when :no_names
            value << 'Ignore the following blogs during processing.'
            value << example
          when :last_tag
            value << 'Use the last available tag for these blogs.'
            value << example
          when :tag_idx
            value = [
              ['Use the first tag for these blogs.',example],
              ['Use the second tag for these blogs.',example],
              ['Use the third tag for these blogs.',example]
            ]
          when :summary
            value << 'Capitalize, add prefix and postfix'
            value << example
          end
          store(@ystore, key, value)
        end
      end
    end

  end
end
