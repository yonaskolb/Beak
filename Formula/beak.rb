class Beak < Formula
  desc "A command line interface for your Swift scripts"
  homepage "https://github.com/yonaskolb/Beak"
  url "https://github.com/yonaskolb/Beak/archive/0.5.1.tar.gz"
  sha256 "83aa529a03af3477e9d8a3a97b48ef56ec6ffe605717cb887d3960313c2b10ce"
  head "https://github.com/yonaskolb/Beak.git"

  depends_on :xcode

  def install
       
    # fixes an issue an issue in homebrew when both Xcode 9.3+ and command line tools are installed
    # see more details here https://github.com/Homebrew/brew/pull/4147
    ENV["CC"] = Utils.popen_read("xcrun -find clang").chomp

    build_path = "#{buildpath}/.build/release/beak"
    ohai "Building Beak"
    system("swift build --disable-sandbox -c release")
    bin.install build_path
  end
end
