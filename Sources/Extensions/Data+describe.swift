import Foundation

extension Data {
    func describe() -> String {
        guard let output = String(data: self, encoding: .utf8) else {
            return ""
        }

        guard !output.hasSuffix("\n") else {
            let endIndex = output.index(before: output.endIndex)
            return String(output[..<endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
