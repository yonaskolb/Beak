class Beak < Formula
  desc "A command line interface for your Swift scripts"
  homepage "https://github.com/yonaskolb/Beak"
  url "https://github.com/yonaskolb/Beak/archive/0.5.0.tar.gz"
  sha256 "cee75df91c8a37318bdb08852e751021f8e34d2483ad6edfef2d5a6cafbe31fb"
  head "https://github.com/yonaskolb/Beak.git"

  depends_on :xcode

  def install
       
    # fixes an issue an issue in homebrew when both Xcode 9.3+ and command line tools are installed
    # see more details here https://github.com/Homebrew/brew/pull/4147
    ENV["CC"] = Utils.popen_read("xcrun -find clang").chomp

    build_path = "#{buildpath}/.build/release/beak"
    ohai "Building Beak"
    system("swift build --disable-sandbox -c release -Xswiftc -static-stdlib")
    bin.install build_path
  end
end
