import BeakCore
import Foundation
import PathKit
import Utility

func tryCommand(_ closure: () throws -> Void) {
    do {
        try closure()
    } catch {
        print("⚠️  \(error)")
        exit(1)
    }
}

let options = BeakOptions()
let beak = Beak(options: options)
tryCommand {
    try beak.execute(arguments: Array(ProcessInfo.processInfo.arguments.dropFirst()))
}
