// beak: kareman/SwiftShell @ 4.0.0
// beak: sharplet/Regex @ 1.1.0
// beak: kylef/PathKit @ 0.8.0

import Foundation
import SwiftShell
import Regex
import PathKit

let tool = "beak"
let repo = "https://github.com/yonaskolb/Beak"

/// Formats all the code in the project
public func formatCode() throws {
    let formatOptions = "--wraparguments beforefirst --stripunusedargs closure-only --header strip"
    try runAndPrint(bash: "swiftformat Sources \(formatOptions)")
    try runAndPrint(bash: "swiftformat Tests \(formatOptions)")
}

/// Installs beak
///
/// - Parameters:
///   - directory: The directory to install beak
public func install(directory: String = "/usr/local/bin") throws {
    print("🐦  Building Beak...")
    let output = run(bash: "swift build --disable-sandbox -c release -Xswiftc -static-stdlib")
    if let error = output.error {
        print("Couldn't build:\n\(error)")
        return
    }
    try runAndPrint(bash: "cp -R .build/release/\(tool) \(directory)/\(tool)")
    print("🐦  Installed Beak!")
}

/// Updates homebrew formular to a certain version
///
/// - Parameters:
///   - version: The version to release
public func updateBrew(_ version: String) throws {
  let releaseTar = "\(repo)/archive/\(version).tar.gz"
  let output = run(bash: "curl -L -s $(RELEASE_TAR) | shasum -a 256 | sed 's/ .*//'")
  guard output.succeeded else {
    print("Error retrieving brew SHA")
    return
  }
  let sha = output.stdout

  try replaceFile(
      regex: "(url \".*/archive/)(.*).tar.gz",
      replacement: "$1\(version).tar.gz",
      path: "Formula/beak.rb")

  try replaceFile(
      regex: "sha256 \".*\"",
      replacement: "sha256 \"\(sha)\"",
      path: "Formula/beak.rb")

  //run(bash: "git add Formula/beak.rb")
  //run(bash: "git commit -m \"Updated brew to \(version)\"")
}

/// Releases a new version of Beak
///
/// - Parameters:
///   - version: The version to release
public func release(_ version: String) throws {

    try replaceFile(
        regex: "public let version: String = \".*\"",
        replacement: "public let version: String = \"\(version)\"",
        path: "Sources/BeakCore/Beak.swift")

    run(bash: "git add Sources/BeakCore/Beak.swift")
    run(bash: "git commit -m \"Updated to \(version)\"")
    run(bash: "git tag \(version)")

    print("🐦  Released version \(version)!")
}

func replaceFile(regex: String, replacement: String, path: Path) throws {
    let regex = try Regex(string: regex)
    let contents: String = try path.read()
    let replaced = contents.replacingFirst(matching: regex, with: replacement)
    try path.write(replaced)
}

func runMint(package: String, command: String?) {

}
