import PathKit
import SwiftCLI
import BeakCore

struct GlobalOptions {
    static let path = Key<String>("-p", "--path", description: "The path to a swift file. Defaults to beak.swift")
    private init() {}
}

protocol BeakCommand: Command {
    func execute(path: Path, beakFile: BeakFile) throws
}

extension BeakCommand {
    
    var path: Key<String> {
        return GlobalOptions.path
    }
    
    func execute() throws {
        let path = Path(self.path.value ?? "beak.swift").normalize()
        let beakFile = try BeakFile(path: path)
        try execute(path: path, beakFile: beakFile)
    }
    
}
