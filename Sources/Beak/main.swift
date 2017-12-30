import BeakCore
import Foundation
import PathKit
import Utility

func tryCommand(_ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        if let error = error as? BeakError {
            print(error.description)
        }
        if let error = error as? ArgumentParserError {
            print(error.description)
        } else {
            print(error.localizedDescription)
        }
        exit(1)
    }
}

let options = BeakOptions()
let beak = Beak(options: options)
tryCommand {
    try beak.execute(arguments: Array(ProcessInfo.processInfo.arguments.dropFirst()))
}
