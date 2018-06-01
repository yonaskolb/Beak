import PathKit
import SwiftCLI
import BeakCore

class ListCommand: BeakCommand {

    let name = "list"
    let shortDescription = "Lists all functions"

    func execute(path: Path, beakFile: BeakFile) throws {
        stdout <<< "Functions:"
        stdout <<< ""
        beakFile.functions.forEach { function in
            stdout <<< "  \(function.name): \(function.docsDescription ?? "")"
        }
        stdout <<< ""
    }
}
