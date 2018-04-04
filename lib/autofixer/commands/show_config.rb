module DK
  class Idable
    def show_config(args)
      return unless args.include?('config')
      `open #{@config_dir + 'view_config.html'}`
      exit(0)
    end
  end
end
