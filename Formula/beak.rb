class Beak < Formula
  desc "A command line interface for your Swift scripts"
  homepage "https://github.com/yonaskolb/Beak"
  url "https://github.com/yonaskolb/Beak/archive/0.3.2.tar.gz"
  sha256 "762f6c0f08a03ad1bf4f386aba852256f04628080f5ce5f2423778f0d523d0aa"
  head "https://github.com/yonaskolb/Beak.git"

  depends_on :xcode

  def install
    build_path = "#{buildpath}/.build/release/beak"
    ohai "Building Beak"
    system("swift build --disable-sandbox -c release -Xswiftc -static-stdlib")
    bin.install build_path
  end
end
