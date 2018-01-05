import BeakCore
import Foundation
import PathKit
import Utility

do {
    let options = BeakOptions()
    let beak = Beak(options: options)
    try beak.execute(arguments: Array(ProcessInfo.processInfo.arguments.dropFirst()))
} catch {
    if error._domain == NSCocoaErrorDomain {
        print("⚠️  \(error.localizedDescription)")
    } else {
        print("⚠️  \(error)")
    }
    exit(1)
}
