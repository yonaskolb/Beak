import Foundation
import Utility
import PathKit
import SwiftShell

class VersionCommand: BeakCommand {

    let version: String

    init(options: BeakOptions, parentParser: ArgumentParser, version: String) {
        self.version = version
        super.init(
            options: options,
            parentParser: parentParser,
            name: "version",
            description: "Prints the current version of beak"
        )
    }

    override func execute(parsedArguments: ArgumentParser.Result) throws {
        print(version)
    }
}

