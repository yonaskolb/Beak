class Beak < Formula
  desc "Command-line interface for your Swift scripts"
  homepage "https://github.com/yonaskolb/Beak"
  url "https://github.com/yonaskolb/Beak.git", :tag => "0.4.0", :revision => "8508e02da82c279b3cf1719bd226dc8c94538a71"

  depends_on :xcode => ["10.0", :build]

  def install
    system "make", "install", "prefix=#{prefix}"
  end

  test do
    system bin/"beak", "version"
  end
end
