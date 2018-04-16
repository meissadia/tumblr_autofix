require 'tumblr_draftking'
require 'yaml/store'
require 'sanitize'
require 'fileutils'
require 'byebug'
Dir[File.join(__dir__, 'autofixer', '**', '*.rb')].each {|file| require file }

if __FILE__ == $0
  DK::Autofixer.new(ARGV)
end
