module DK
  class Idable
    def show_help(args, opts)
      return unless (args.include?('help') || opts.find_index('-h'))
      puts 'Usage: '
      puts '  $ taf <command?> [options?]'
      puts
      puts ' Commands:'
      puts '    help   Show this menu.'
      puts '    show   Open a webpage with the latest taf results.'
      puts
      puts ' Options:'
      puts '    -s             Simulate Run (no changes saved)'
      puts '    -p [STRING]    Prefix for generated comments'
      puts '    -P [STRING]    Prefix for generated comments'
      puts '    -S [STRING]    Separator used between prefix/postfix and generated comment text.'
      puts '    -l [INTEGER]   Number of Drafts to select for processing.'
      puts '    --clear        Clear unprocessible Drafts by adding the given prefix (-p [STRING])'
      puts '                    causing these posts to show as "Already Processed" in future runs.'
      puts '    --show         Open the results webpage after processing is complete.'
      exit(0)
    end
  end
end
