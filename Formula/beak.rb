class Beak < Formula
  desc "A command line interface for your Swift scripts"
  homepage "https://github.com/yonaskolb/Beak"
  url "https://github.com/yonaskolb/Beak/archive/0.3.0.tar.gz"
  sha256 "eff35feb43563876689dbcc19aa22142e5f717f86e9565fb699964c1f373c8c2"
  head "https://github.com/yonaskolb/Beak.git"

  depends_on :xcode

  def install
    build_path = "#{buildpath}/.build/release/beak"
    ohai "Building Beak"
    system("swift build --disable-sandbox -c release -Xswiftc -static-stdlib")
    bin.install build_path
  end
end
