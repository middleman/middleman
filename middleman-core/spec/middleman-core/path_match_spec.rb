require 'middleman-core/util'

describe "Middleman::Util#path_match" do
  it "matches a literal string" do
    expect(Middleman::Util.path_match '/index.html', '/index.html').to be true
  end

  it "won't match a wrong string" do
    expect(Middleman::Util.path_match '/foo.html', '/index.html').to be false
  end

  it "won't match a partial string" do
    expect(Middleman::Util.path_match 'ind', '/index.html').to be false
  end

  it "works with a regex" do
    expect(Middleman::Util.path_match /\.html$/, '/index.html').to be true
    expect(Middleman::Util.path_match /\.js$/, '/index.html').to be false
  end

  it "works with a proc" do
    matcher = lambda {|p| p.length > 5 }

    expect(Middleman::Util.path_match matcher, '/index.html').to be true
    expect(Middleman::Util.path_match matcher, '/i').to be false
  end

  it "works with globs" do
    expect(Middleman::Util.path_match '/foo/*.html', '/foo/index.html').to be true
    expect(Middleman::Util.path_match '/foo/*.html', '/foo/index.js').to be false
    expect(Middleman::Util.path_match '/bar/*.html', '/foo/index.js').to be false

    expect(Middleman::Util.path_match '/foo/*', '/foo/bar/index.html').to be true
    expect(Middleman::Util.path_match '/foo/**/*', '/foo/bar/index.html').to be true
    expect(Middleman::Util.path_match '/foo/**', '/foo/bar/index.html').to be true
  end
end
