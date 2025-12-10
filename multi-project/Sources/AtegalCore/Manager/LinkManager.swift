//
//  Created by Michele Restuccia on 11/11/25.
//

import Foundation

public enum MapsApp {
    case apple, google
}

public class LinkManager {

    @MainActor
    public static let shared = LinkManager()
    
    private init() {}
    
    @MainActor
    public func phoneURL(for rawPhoneNumber: String) -> URL? {
        let allowedCharacters = "+0123456789"
        let sanitized = rawPhoneNumber
            .filter { allowedCharacters.contains($0) }
        
        guard !sanitized.isEmpty else { return nil }
        return URL(string: "tel://\(sanitized)")
    }
    
    public func websiteURL(from raw: String) -> URL? {
        guard !raw.isEmpty else { return nil }
        if let url = URL(string: raw), url.scheme != nil {
            return url
        }
        let prefixed = "https://\(raw)"
        return URL(string: prefixed)
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
    
    public func androidCalendar(for event: Event, duration: TimeInterval = 3600) -> URL {
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
    public func androidMapsURL(for address: String) -> URL? {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? address
        return URL(string: "https://www.google.com/maps/search/?api=1&query=\(encoded)")
    }
}

// MARK: Extensions

#if canImport(Darwin)

import EventKit
import UIKit

public extension LinkManager {
    
    @MainActor
    func open(on app: MapsApp, lat: Double, lon: Double) {
        switch app {
        case .apple:
            let url = URL(string: "http://maps.apple.com/?daddr=\(lat),\(lon)&dirflg=d")!
            UIApplication.shared.open(url)
        case .google:
            let appScheme = URL(string: "comgooglemaps://")!
            if UIApplication.shared.canOpenURL(appScheme) {
                let url = URL(string: "comgooglemaps://?daddr=\(lat),\(lon)&directionsmode=driving")!
                UIApplication.shared.open(url)
            } else {
                let url = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lon)")!
                UIApplication.shared.open(url)
            }
        }
    }

    @MainActor
    func addToAppleCalendar(event: Event) async -> Bool {
        let store = EKEventStore()
        do {
            try await store.requestFullAccessToEvents()
        } catch {
            return false
        }
        let ekEvent = EKEvent(eventStore: store)
        ekEvent.title = event.title
        ekEvent.notes = event.description
        ekEvent.startDate = event.startDate
        ekEvent.endDate = event.startDate.addingTimeInterval(60 * 60)
        let calendar = try? findCalendar(in: store)

        guard let calendar else { return false }
        ekEvent.calendar = calendar
        do {
            try store.save(ekEvent, span: .thisEvent, commit: true)
            return true
        } catch {
            return false
        }
    }

    private func findCalendar(in store: EKEventStore) throws -> EKCalendar? {
        if let calendar = store.defaultCalendarForNewEvents
            ?? store.calendars(for: .event).first(where: { $0.allowsContentModifications }) {
            return calendar
        }
        let newCalendar = EKCalendar(for: .event, eventStore: store)
        newCalendar.title = "ategal-title"
        let sources = store.sources
        guard let source =
            store.defaultCalendarForNewEvents?.source ??
            sources.first(where: { $0.sourceType == .local }) ??
            sources.first(where: { $0.sourceType == .calDAV }) ??
            sources.first(where: { $0.sourceType == .exchange }) ??
            sources.first
        else {
            return nil
        }

        newCalendar.source = source
        try store.saveCalendar(newCalendar, commit: true)
        return newCalendar
    }
}
#endif
