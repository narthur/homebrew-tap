class Buzz < Formula
  desc "Terminal user interface for Beeminder"
  homepage "https://github.com/PinePeakDigital/buzz"
  url "https://github.com/PinePeakDigital/buzz/archive/refs/tags/v0.69.0.tar.gz"
  sha256 "702cb2a773783a01d08e72a2662470d1211bfccf85e896442d6662db4736fb40"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "buzz", shell_output("#{bin}/buzz --help 2>&1", 1)
  end
end
