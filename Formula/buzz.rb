class Buzz < Formula
  desc "Terminal user interface for Beeminder"
  homepage "https://github.com/narthur/buzz"
  url "https://github.com/narthur/buzz/archive/refs/tags/v0.12.0.tar.gz"
  sha256 "dedef43d27aa1323c4324438646242e53d44d2ac1d094fc93ae588372e24307f"
  license "MIT"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match "buzz", shell_output("#{bin}/buzz --help 2>&1", 1)
  end
end
