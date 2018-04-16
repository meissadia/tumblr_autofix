require_relative 'testing_helper'

class AfHelperTest < Minitest::Test
  def setup
  end

  def test_capitalize
    af = DK::Autofixer.new
    str = 'alaskan 999 amber yum'
    exp = 'Alaskan Amber Yum'
    assert_equal af.send(:capitalize, str), exp
  end

  def test_affix
    af = DK::Autofixer.new(%w(-p ^ -P $ -S _))
    str = 'hello world'
    exp = "^ _ hello world _ $"
    assert_equal exp, af.send(:affix, str)
    af = DK::Autofixer.new(%w(-p ^ -S _))
    str = 'hello world'
    exp = "^ _ hello world"
    assert_equal exp, af.send(:affix, str)
  end

  def test_link_to_edit
    af = DK::Autofixer.new
    link = af.send(:link_to_edit, '1234')
    exp = "https://www.tumblr.com/edit/1234"
    assert_equal exp, link
    link = af.send(:link_to_edit, 1234)
    exp = "https://www.tumblr.com/edit/1234"
    assert_equal exp, link
  end

  def test_pad
    af = DK::Autofixer.new
    exp = '     2'
    assert_equal exp, af.send(:pad, 2, 100000, true)
    exp = '2     '
    assert_equal exp, af.send(:pad, 2, 100000)
  end

end
