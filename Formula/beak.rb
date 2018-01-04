class Beak < Formula
  desc "A command line interface for your Swift scripts"
  homepage "https://github.com/yonaskolb/Beak"
  url "https://github.com/yonaskolb/Beak/archive/0.2.0.tar.gz"
  sha256 "76f7c837ed9d393e7de24173dd728b73d9d5b5e5a923f6c2c1d50be4ee105426"
  head "https://github.com/yonaskolb/Beak.git"

  depends_on :xcode

  def install
    build_path = "#{buildpath}/.build/release/beak"
    ohai "Building Beak"
    system("swift build --disable-sandbox -c release -Xswiftc -static-stdlib")
    bin.install build_path
  end
end
