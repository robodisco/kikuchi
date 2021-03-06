require_relative "helper"


class TestPage < Test::Unit::TestCase
  def test_read_content
    p = Page.new(File.join(File.dirname(__FILE__), "fixtures"), "about.html")
    p.read_content
    assert_equal "<h1>About</h1>", p.content
  end

  def test_render
    p = Page.new(File.join(File.dirname(__FILE__), "fixtures"), "about.html")
    p.read_content
    p.render({})
    assert_equal "<h1>About</h1>", p.output
  end

  def test_render_with_layouts
    p = Page.new(File.join(File.dirname(__FILE__), "fixtures"), "about.html")
    inner = Layout.allocate.tap{|l| l.content = '<div id="inner">{{content}}</div>'}
    outer = Layout.allocate.tap{|l| l.content = '<div id="outer">{{content}}</div>'}
    p.render({}, [inner, outer])
    assert_equal %Q{<div id="outer"><div id="inner"><h1>About</h1></div></div>}, p.output
  end

  def test_render_with_payload
    p = Page.new(File.join(File.dirname(__FILE__), "fixtures"), "index.html")
    post = Post.create(File.join(File.dirname(__FILE__), "fixtures", "posts"), "2005-12-31-this-is-a-post.markdown") 
    p.read_content
    payload = {'site' => {'posts' => [post]}}
    p.render(payload, [])
    assert_match /#{post.title}/, p.output
  end

  def test_write
    clear_dest
    p = Page.new(File.join(File.dirname(__FILE__), "fixtures"), "about.html")
    p.write(dest)
    assert File.exists? File.join(dest, p.name)
  end 
end