import Foundation

extension FileHandle {
    var isStandard: Bool {
        self === FileHandle.standardOutput ||
        self === FileHandle.standardError ||
        self === FileHandle.standardInput
    }
}
