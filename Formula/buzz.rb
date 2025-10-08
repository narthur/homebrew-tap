class Buzz < Formula
  desc "Terminal user interface for Beeminder"
  homepage "https://github.com/narthur/buzz"
  url "https://github.com/narthur/buzz/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "f4f04d8856eb3533ef0b2a2bf142427e1f7a6193be2b9da1d0e467b0f1eb12fa"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "buzz", shell_output("#{bin}/buzz --help 2>&1", 1)
  end
end
