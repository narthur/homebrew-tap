class Buzz < Formula
  desc "Terminal user interface for Beeminder"
  homepage "https://github.com/PinePeakDigital/buzz"
  url "https://github.com/PinePeakDigital/buzz/archive/refs/tags/v0.30.0.tar.gz"
  sha256 "51d916ec3afea5fe43317b583fba5a673a054743e46961f11e6489c00f96a419"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "buzz", shell_output("#{bin}/buzz --help 2>&1", 1)
  end
end
