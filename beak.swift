// beak: kareman/SwiftShell @ 4.0.0
// beak: sharplet/Regex @ 1.1.0
// beak: kylef/PathKit @ 0.8.0

import Foundation
import SwiftShell
import Regex
import PathKit

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
    try runAndPrint(bash: "cp -R .build/release/beak \(directory)/beak")
    print("🐦  Installed Beak!")
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
