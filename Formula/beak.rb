class Beak < Formula
  desc "A command line interface for your Swift scripts"
  homepage "https://github.com/yonaskolb/Beak"
  url "https://github.com/yonaskolb/Beak/archive/0.2.0.tar.gz"
  sha256 "76f7c837ed9d393e7de24173dd728b73d9d5b5e5a923f6c2c1d50be4ee105426"
  head "https://github.com/yonaskolb/Beak.git"

  depends_on :xcode

  def install
    system "swift run beak run install"
  end
end
