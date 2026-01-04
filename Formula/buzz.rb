class Buzz < Formula
  desc "Terminal user interface for Beeminder"
  homepage "https://github.com/PinePeakDigital/buzz"
  url "https://github.com/PinePeakDigital/buzz/archive/refs/tags/v0.48.0.tar.gz"
  sha256 "4eeeca8713e71c3512d03b42c9760b1bf23115bc37af7fd7d3a794de9f32bccc"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "buzz", shell_output("#{bin}/buzz --help 2>&1", 1)
  end
end
