require_relative "helper"


class TestPost < Test::Unit::TestCase
  def test_valid
    assert Post.valid?("2005-12-31-this-is-post.markdown")
    assert !Post.valid?("2005-12-31.markdown")
  end

  def test_process
    post = Post.allocate
    post.process("2005-12-31-this-is-a-post.markdown")
    assert_equal Time.strptime("2005-12-31","%Y-%m-%d"), post.date
    assert_equal "this-is-a-post", post.slug
    assert_equal ".markdown", post.extension
  end

  def test_render
    p = Post.create(File.join(File.dirname(__FILE__), *%w[fixtures posts]), "2005-12-31-this-is-a-post.markdown") 
    p.render 
    assert_equal %Q{<h1>This is my first post</h1>}, p.output 
  end

  def test_render_with_layouts
    p = Post.create(File.join(File.dirname(__FILE__), "fixtures", "posts"), "2005-12-31-this-is-a-post.markdown") 
    inner = Layout.allocate.tap{|l| l.content = '<div id="inner">{{content}}</div>'}
    outer = Layout.allocate.tap{|l| l.content = '<div id="outer">{{content}}</div>'}
    p.render([inner, outer])
    assert_equal %Q{<div id="outer"><div id="inner"><h1>This is my first post</h1></div></div>}, p.output
  end

  def test_dir
    p = Post.allocate
    p.date = Time.strptime("2005-12-31","%Y-%m-%d")
    assert_equal "2005/12/31", p.dir
  end

  def test_url
    p = Post.create(File.join(File.dirname(__FILE__), "fixtures", "posts"), "2005-12-31-this-is-a-post.markdown") 
    assert_match "posts/2005/12/31/this-is-a-post", p.url
  end

  def test_write
    clear_dest
    post = Post.create( File.join(File.dirname(__FILE__), *%w[fixtures posts]), "2005-12-31-this-is-a-post.markdown")
    post.render
    post.write(dest)
    assert File.exists?(File.join(dest, post.dir, 'this-is-a-post.html'))
  end

  def test_title
    p = Post.allocate
    p.slug = "this-is-a-post"
    assert_equal "This Is A Post", p.title
  end
end