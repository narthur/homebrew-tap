class Buzz < Formula
  desc "Terminal user interface for Beeminder"
  homepage "https://github.com/narthur/buzz"
  url "https://github.com/narthur/buzz/archive/refs/tags/v0.14.0.tar.gz"
  sha256 "d6be2ac1fd5fce4462357d21f06ea80bb37a5ae1155ecf71fbf861b68483fd28"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "buzz", shell_output("#{bin}/buzz --help 2>&1", 1)
  end
end
