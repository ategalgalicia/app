//
//  Created by Michele Restuccia on 11/11/25.
//

import Foundation

public class ExternalActions {

    @MainActor
    public static let shared = ExternalActions()
    
    private init() {}
    
    public func url(for event: Event, duration: TimeInterval = 3600) -> URL {
        func enc(_ s: String) -> String {
            s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
        }

        let endDate = event.startDate.addingTimeInterval(duration)

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"

        let startStr = formatter.string(from: event.startDate)
        let endStr   = formatter.string(from: endDate)

        let base = "https://calendar.google.com/calendar/render"
        let query = "action=TEMPLATE&text=\(enc(event.title))&details=\(enc(event.description ?? ""))&dates=\(startStr)/\(endStr)"

        return URL(string: "\(base)?\(query)")!
    }
    
    @MainActor
    public func phoneURL(for rawPhoneNumber: String) -> URL? {
        let allowedCharacters = "+0123456789"
        let sanitized = rawPhoneNumber
            .filter { allowedCharacters.contains($0) }
        
        guard !sanitized.isEmpty else { return nil }
        return URL(string: "tel://\(sanitized)")
    }
    
    @MainActor
    public func googleMapsURL(for address: String) -> URL? {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? address
        
        #if canImport(Darwin)
        if let appURL = URL(string: "comgooglemaps://?q=\(encoded)"),
           UIApplication.shared.canOpenURL(appURL) {
            return appURL
        }
        #endif
        return URL(string: "https://www.google.com/maps/search/?api=1&query=\(encoded)")
    }
    
    public func emailURL(to email: String, subject: String? = nil, body: String? = nil) -> URL? {
        guard !email.isEmpty else { return nil }
        var components = "mailto:\(email)"
        var params: [String] = []
        
        if let subject, !subject.isEmpty {
            let enc = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
            params.append("subject=\(enc)")
        }
        if let body, !body.isEmpty {
            let enc = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? body
            params.append("body=\(enc)")
        }
        if !params.isEmpty {
            components += "?" + params.joined(separator: "&")
        }
        return URL(string: components)
    }
    
    public func websiteURL(from raw: String) -> URL? {
        guard !raw.isEmpty else { return nil }
        if let url = URL(string: raw), url.scheme != nil {
            return url
        }
        let prefixed = "https://\(raw)"
        return URL(string: prefixed)
    }
    
    enum Error: Swift.Error {
        case notSupported
    }
}

// MARK: Extensions

#if canImport(Darwin)

import EventKit
import UIKit

public extension ExternalActions {

    @MainActor
    func addToAppleCalendar(event: Event) async throws {
        let store = EKEventStore()
        do {
            try await store.requestFullAccessToEvents()
        } catch {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                await UIApplication.shared.open(url)
            }
            throw error
        }

        let ekEvent = EKEvent(eventStore: store)
        ekEvent.title = event.title
        ekEvent.notes = event.description
        ekEvent.startDate = event.startDate
        ekEvent.endDate = event.startDate.addingTimeInterval(60 * 60)

        if let cal = store.defaultCalendarForNewEvents ?? store.calendars(for: .event).first(where: { $0.allowsContentModifications }) {
            ekEvent.calendar = cal
        } else {
            let cal = EKCalendar(for: .event, eventStore: store)
            cal.title = "Ategal"
            cal.source = store.defaultCalendarForNewEvents?.source
                ?? store.sources.first(where: { $0.sourceType == .local })
                ?? store.sources.first!
            try store.saveCalendar(cal, commit: true)
            ekEvent.calendar = cal
        }
        try store.save(ekEvent, span: .thisEvent, commit: true)
    }
}
#endif
