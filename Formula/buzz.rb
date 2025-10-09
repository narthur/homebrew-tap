class Buzz < Formula
  desc "Terminal user interface for Beeminder"
  homepage "https://github.com/narthur/buzz"
  url "https://github.com/narthur/buzz/archive/refs/tags/v0.11.0.tar.gz"
  sha256 "605222a3a25eb9bd61b38772a218f2ed18fd411628450098464f3d4153938665"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "buzz", shell_output("#{bin}/buzz --help 2>&1", 1)
  end
end
