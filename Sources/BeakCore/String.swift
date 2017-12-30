import Foundation

extension String {

    func substring(start: Int, end: Int) -> String {
        return substring(start: start, length: end - start)
    }

    func substring(start: Int, length: Int) -> String {
        let left = index(startIndex, offsetBy: start)
        let right = index(left, offsetBy: length)
        return String(self[left ..< right])
    }

    var quoted: String {
        return "\"\(self)\""
    }
}
