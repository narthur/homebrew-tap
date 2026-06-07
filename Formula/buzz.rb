class Buzz < Formula
  desc "Terminal user interface for Beeminder"
  homepage "https://github.com/PinePeakDigital/buzz"
  url "https://github.com/PinePeakDigital/buzz/archive/refs/tags/v0.71.1.tar.gz"
  sha256 "f3838d549362e986535ed91bd31a54d33f6244a1b80514380596670d33758463"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "buzz", shell_output("#{bin}/buzz --help 2>&1", 1)
  end
end
