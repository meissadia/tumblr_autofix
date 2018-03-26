module DK
  class Idable
    def show_version(opts)
      return unless opts.include?('-v')
      puts "\ntumblr_autofixer v0.0.1"
      puts
      exit(0)
    end
  end
end
