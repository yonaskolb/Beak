class Beak < Formula
  desc "A command line interface for your Swift scripts"
  homepage "https://github.com/yonaskolb/Beak"
  url "https://github.com/yonaskolb/Beak/archive/0.3.1.tar.gz"
  sha256 "437d1b7af73d27309f68eb19f685aa6e7ecb5fa1ec5f667804c355146ab42d02"
  head "https://github.com/yonaskolb/Beak.git"

  depends_on :xcode

  def install
    build_path = "#{buildpath}/.build/release/beak"
    ohai "Building Beak"
    system("swift build --disable-sandbox -c release -Xswiftc -static-stdlib")
    bin.install build_path
  end
end
