//
//  Created by Michele Restuccia on 11/11/25.
//

import Foundation
import SwiftUI

public final class CalendarService {

    @MainActor
    public static let shared = CalendarService()
    
    private init() {}

    @MainActor
    public func addToCalendar(event: Event) async throws {
        #if canImport(EventKit)
        try await addToAppleCalendar(event: event)
        #endif
    }
    
    public func url(for event: Event, duration: TimeInterval = 3600) -> URL {
        func enc(_ s: String) -> String {
            s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
        }
        let startMs = Int64(event.startDate.timeIntervalSince1970 * 1000)
        let endMs   = Int64(event.startDate.addingTimeInterval(duration).timeIntervalSince1970 * 1000)
        let q = "title=\(enc(event.title))&desc=\(enc(event.description ?? ""))&start=\(startMs)&end=\(endMs)"
        return URL(string: "ategal://calendar/add?\(q)")!
    }
    
    enum Error: Swift.Error {
        case notSupported
    }
}

#if canImport(EventKit)
import EventKit

private extension CalendarService {

    @MainActor
    func addToAppleCalendar(event: Event) async throws {
        let store = EKEventStore()
        do {
            try await store.requestFullAccessToEvents()
        } catch {
            #if canImport(UIKit)
            if let url = URL(string: UIApplication.openSettingsURLString) {
                await UIApplication.shared.open(url)
            }
            #endif
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

private extension CalendarService {
    func androidDeepLink(for event: Event, duration: TimeInterval = 3600) -> URL? {
        func enc(_ s: String) -> String {
            s.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? s
        }
        let startMs = Int64(event.startDate.timeIntervalSince1970 * 1000)
        let endMs   = Int64(event.startDate.addingTimeInterval(duration).timeIntervalSince1970 * 1000)
        let q = "title=\(enc(event.title))&desc=\(enc(event.description ?? ""))&start=\(startMs)&end=\(endMs)"
        return URL(string: "ategal://calendar/add?\(q)")
    }
}
