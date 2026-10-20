import Foundation

public struct Announcement: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let body: String
    public let topic: PushTopic
    public let publishedAt: Date
    public let action: Action?
    
    public enum Action: Hashable, Sendable {
        case activity(title: String, centerID: String)
        case calendar(day: String)
    }

    public init(
        id: String,
        title: String,
        body: String,
        publishedAt: Date,
        topic: PushTopic,
        action: Action? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.topic = topic
        self.action = action
        self.publishedAt = publishedAt
    }
}

extension Announcement.Action {
    
    public var isValid: Bool {
        switch self {
        case .activity(let title, let centerID):
            return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !centerID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        case .calendar(let day):
            let formatter = Self.dayFormatter
            guard day.count == 10, let date = formatter.date(from: day) else {
                return false
            }
            return formatter.string(from: date) == day
        }
    }

    public var payload: [String: String] {
        switch self {
        case .activity(let title, let centerID):
            return ["type": "activity", "title": title, "centerID": centerID]
            
        case .calendar(let day):
            return ["type": "calendar", "day": day]
        }
    }

    public init?(payload: [String: String]) {
        switch payload["type"] {
        case "activity":
            guard payload.count == 3,
                  let title = payload["title"],
                  let centerID = payload["centerID"] else { return nil }
            self = .activity(title: title, centerID: centerID)
            
        case "calendar":
            guard payload.count == 2,
                  let day = payload["day"] else { return nil }
            self = .calendar(day: day)
            
        default:
            return nil
        }
        guard isValid else { return nil }
    }

    public static func calendarDay(from date: Date) -> String {
        dayFormatter.string(from: date)
    }

    public var calendarDate: Date? {
        guard case .calendar(let day) = self, isValid else { return nil }
        return Self.dayFormatter.date(from: day)
    }

    public struct ActivityMatch: Identifiable, Sendable {
        public let id: String
        public let center: Center
        public let activity: Center.Category.Activity
    }

    public func matchingActivities(in centers: [Center]) -> [ActivityMatch] {
        guard case .activity(let title, let centerID) = self else { return [] }
        return centers.filter { $0.id == centerID }.flatMap { center in
            center.categories.flatMap { category in
                category.activities.filter { $0.title == title }.map { activity in
                    ActivityMatch(
                        id: "\(center.id)|\(category.id)|\(activity.id)",
                        center: center,
                        activity: activity
                    )
                }
            }
        }
    }

    private static var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = false
        return formatter
    }
}
