// beak: kareman/SwiftShell @ 4.0.0
import Foundation
import SwiftShell

/// Formats all the code in the project
public func formatCode() throws {
  let formatOptions = "--wraparguments beforefirst --stripunusedargs closure-only --header strip"
  try runAndPrint(bash: "swiftformat Sources \(formatOptions)")
  try runAndPrint(bash: "swiftformat Tests \(formatOptions)")
}

/// Installs beak
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

func runMint(package: String, command: String?) {

}
