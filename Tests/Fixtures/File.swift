// beak: kareman/SwiftShell @ 4.0.0
import Foundation

/// This lists all the functions
///
/// - Parameters:
///   - verbose: The verbosity
///   - path: The path to the file
///   - doIt: Do it?
/// - Throws: any errors
public func list(path: String, verbose: Bool = false, doIt: Bool = true) throws {
    print("ran list")
}

/// release version
public func release(_ version: String) {
    helper()
    print("ran release \(version)")
}

func helper() {
}

print("ran file")
