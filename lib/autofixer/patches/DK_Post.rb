module DK
  class Post
    # Post has a summary or tags?
    def has_info?
      has_summary? || !tags.empty?
    end

    # Do we know where it was reblogged from?
    def has_trail?
      !trail.empty?
    end

    # Post already has prefix?
    def processed?(skip: false, prefix: '')
      return false if skip
      return false if prefix.empty?
      l_comment = Sanitize.fragment(comment).strip
      l_comment.start_with?(prefix) || summary.strip.start_with?(prefix)
    end

    def has_summary?
      summary.strip.empty?
    end
  end
end
