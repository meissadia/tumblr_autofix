module DK
  class Idable
    def show_version(opts)
      return unless opts.include?('-v')
      puts "\ntumblr_autofixer v#{VERSION}"
      puts
      exit(0)
    end
  end
end
