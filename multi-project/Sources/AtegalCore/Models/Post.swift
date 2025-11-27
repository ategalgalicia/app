//
//  Created by Michele Restuccia on 29/10/25.
//

import Foundation

public struct Post: Identifiable, Sendable {
    public let id: Int
    public let date: Date
    public let title: String
    public let content: String
    public let imageURL: URL?

    public init(id: Int, date: Date, title: String, content: String, imageURL: URL?) {
        self.id = id
        self.date = date
        self.title = title
        self.content = content
        self.imageURL = imageURL
    }
}

private extension Post {
    
    struct RenderedText: Decodable {
        let rendered: String
    }
}

extension Post: Decodable {

    private enum CodingKeys: String, CodingKey {
        case id, date, title, content
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        date = try {
            let dateString = try container.decode(String.self, forKey: .date)
            guard let parsedDate = DateFormatter.wordpress.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .date, in: container, debugDescription: "Date string could not be parsed"
                )
            }
            return parsedDate
        }()
        title = try decodeRendered(for: .title)
        let rawHTML = try decodeRendered(for: .content)
        imageURL = rawHTML.firstImageURL
        content = rawHTML.stripped
        
        func decodeRendered(for key: CodingKeys) throws -> String {
            try container.decode(RenderedText.self, forKey: key).rendered
        }
    }
}

// MARK: DateFormatter

private extension DateFormatter {
    
    static let wordpress: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
}

// MARK: Extensions

private extension String {

    var stripped: String {
        var text = self
            .replacingOccurrences(of: "<img[^>]*>", with: "", options: .regularExpression)
            .replacingOccurrences(
                of: "<div[^>]*class=['\"]?gallery[^>]*>[\\s\\S]*?</div>",
                with: "",
                options: .regularExpression
            )
            .replacingOccurrences(of: "<br\\s*/?>", with: "\n", options: .regularExpression)
            .replacingOccurrences(of: "</p\\s*>", with: "\n\n", options: .regularExpression)
            .replacingOccurrences(of: "</div\\s*>", with: "\n", options: .regularExpression)
            .replacingOccurrences(of: "</li\\s*>", with: "\n", options: .regularExpression)
            .replacingOccurrences(of: "<li\\s*>", with: "• ", options: .regularExpression)
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        
        let entities: [String: String] = [
            "&nbsp;": " ",
            "&amp;": "&",
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&#39;": "'",
            "&#8211;": "–",
            "&#8212;": "—",
            "&#160;": " "
        ]
        for (key, value) in entities {
            text = text.replacingOccurrences(of: key, with: value)
        }
        return text
            .replacingOccurrences(of: "[ \\t]+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: " *\n *", with: "\n", options: .regularExpression)
            .replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var firstImageURL: URL? {
        let pattern = "<img[^>]*src=[\"']([^\"']+)[\"'][^>]*>"
        guard
            let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
            let match = regex.firstMatch(in: self, range: NSRange(startIndex..., in: self)),
            match.numberOfRanges >= 2,
            let range = Range(match.range(at: 1), in: self)
        else {
            return nil
        }
        return URL(string: String(self[range]))
    }
}
