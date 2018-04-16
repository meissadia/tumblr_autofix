module DK
 class Autofixer
    def show_config
      return unless @options.include?('config')
      `open #{@config_dir + 'view_config.html'}`
      exit(0)
    end
  end
end
