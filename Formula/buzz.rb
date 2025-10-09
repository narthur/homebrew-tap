class Buzz < Formula
  desc "Terminal user interface for Beeminder"
  homepage "https://github.com/narthur/buzz"
  url "https://github.com/narthur/buzz/archive/refs/tags/v0.7.3.tar.gz"
  sha256 "a3fc2ce796ce59e08024f82d2f1b55b5b020c43f631f7c2436603d3c716a7ac3"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "buzz", shell_output("#{bin}/buzz --help 2>&1", 1)
  end
end
