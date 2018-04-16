module DK
 class Autofixer
    def open_results
      return unless @options.include?('open')
      file = confile('updated.html')
      `open #{file}` && exit(0) if File.exist?(file)
      puts
      puts 'Error:'
      puts '  No results have been generated yet.'
      puts
      exit(0)
    end
  end
end
