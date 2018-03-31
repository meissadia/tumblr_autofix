module DK
  class Idable
    def open_results(args)
      return unless args.include?('open')
      file = confile('need_review.html')
      `open #{file}` && exit(0) if File.exist?(file)
      puts
      puts 'Error:'
      puts '  No results have been generated yet.'
      puts
      exit(0)
    end
  end
end
