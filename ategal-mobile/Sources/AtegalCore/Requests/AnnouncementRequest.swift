import Foundation

public struct AnnouncementRequest: Sendable {
    public let id: String
    public let title: String
    public let body: String
    public let topic: PushTopic
    public let action: Announcement.Action?

    public init(
        id: String,
        title: String,
        body: String,
        topic: PushTopic,
        action: Announcement.Action? = nil
    ) {
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        self.topic = topic
        self.action = action
    }

    public var isValid: Bool {
        !id.isEmpty && Self.areFieldsValid(title: title, body: body)
            && (action?.isValid ?? true)
    }

    public static func areFieldsValid(title: String, body: String) -> Bool {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = body.trimmingCharacters(in: .whitespacesAndNewlines)
        return !title.isEmpty && title.unicodeScalars.count <= 120
            && !body.isEmpty && body.unicodeScalars.count <= 2000
    }
}
