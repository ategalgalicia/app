import Foundation

public struct Event: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let startDate: Date
    public let description: String?
    
    public init(id: String, title: String, startDate: Date, description: String? = nil) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.description = description
    }
    
    init?(from block: String) {
        guard
            let uid = block.extractValue(for: "UID"),
            let id = uid.components(separatedBy: "@").first,
            let summary = block.extractValue(for: "SUMMARY"),
            let startRaw = block.extractValue(for: "DTSTART;TZID=Europe/Paris"),
            let startDate = DateFormatter.ategalCalendar.date(from: startRaw)
        else {
            return nil
        }
        self.id = id
        self.title = summary.unescapedICS()
        self.description = block.extractValue(for: "DESCRIPTION")?.unescapedICS()
        self.startDate = startDate
    }
}

// MARK: Extensions

extension String {
    
    func parseAsCalendar() -> [Event] {
        self
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "BEGIN:VEVENT")
            .dropFirst()
            .compactMap { Event(from: $0) }
    }
    
    fileprivate func extractValue(for key: String) -> String? {
        let text = self.replacingOccurrences(of: "\r\n", with: "\n")
        guard let range = text.range(of: "\(key):") else { return nil }
        let tail = text[range.upperBound...]
        var lines = tail.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard !lines.isEmpty else { return nil }
        var value = lines.removeFirst()
        while let next = lines.first, next.first == " " || next.first == "\t" {
            value += next.dropFirst()
            lines.removeFirst()
        }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    fileprivate func unescapedICS() -> String {
        self
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\,", with: ",")
            .replacingOccurrences(of: "\\;", with: ";")
            .replacingOccurrences(of: "\\\\", with: "\\")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: DateFormatter

private extension DateFormatter {
    
    static let ategalCalendar: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Paris")
        formatter.dateFormat = "yyyyMMdd'T'HHmmss"
        return formatter
    }()
}
