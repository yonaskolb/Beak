class Beak < Formula
  desc "A command line interface for your Swift scripts"
  homepage "https://github.com/yonaskolb/Beak"
  url "https://github.com/yonaskolb/Beak/archive/0.3.5.tar.gz"
  sha256 "4048cf34ec3314cff89bddcd138ce0c8fdd0514c4da250014b4354c7fee2c495"
  head "https://github.com/yonaskolb/Beak.git"

  depends_on :xcode

  def install
    build_path = "#{buildpath}/.build/release/beak"
    ohai "Building Beak"
    system("swift build --disable-sandbox -c release -Xswiftc -static-stdlib")
    bin.install build_path
  end
end
