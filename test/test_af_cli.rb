require_relative 'testing_helper'

class AfCliTest < Minitest::Test

  def test_wrong_command
    val = `taf wrong_command`
    assert val.include?('not found')
  end

  def test_valid_command
    val = `taf -v`
    assert /tumblr_autofixer v(\d+.?)+/.match val
  end

end
