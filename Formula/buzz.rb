class Buzz < Formula
  desc "Terminal user interface for Beeminder"
  homepage "https://github.com/PinePeakDigital/buzz"
  url "https://github.com/PinePeakDigital/buzz/archive/refs/tags/v0.84.2.tar.gz"
  sha256 "6783cc2ffc5bd56583913768e093aeffd7c2575369eb4f0ee97699ffae93dde1"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "buzz", shell_output("#{bin}/buzz --help 2>&1", 1)
  end
end
