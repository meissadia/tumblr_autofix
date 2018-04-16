module DK
 class Autofixer
    def show_version
      return unless @options.include?('-v') || @options.include?('--version')
      puts "\ntumblr_autofixer v#{VERSION}"
      puts
      exit(0)
    end
  end
end
