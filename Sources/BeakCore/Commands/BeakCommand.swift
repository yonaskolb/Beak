import PathKit
import SwiftCLI

let _pathKey = Key<String>("--path", "-p", description: "The path to a swift file. Defaults to beak.swift")

protocol BeakCommand: Command {
    func execute(path: Path, beakFile: BeakFile) throws
}

extension BeakCommand {
    
    var path: Key<String> {
        return _pathKey
    }
    
    func execute() throws {
        let path = Path(_pathKey.value ?? "beak.swift").normalize()
        let beakFile = try BeakFile(path: path)
        try execute(path: path, beakFile: beakFile)
    }
    
}
