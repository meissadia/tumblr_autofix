module DK
  class Idable
    def show_version(opts)
      return unless opts.include?('-v')
      puts "\ntumblr_autofixer v0.0.3"
      puts
      exit(0)
    end
  end
end
