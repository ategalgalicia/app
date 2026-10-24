//
//  Created by Michele Restuccia on 11/11/25.
//

import SwiftUI
import AtegalCore
import RStudioKit

#if canImport(Darwin)

// MARK: - Previews

@available(iOS 18, *)
#Preview {
    CalendarView(
        viewModel: .mock(),
        onOpenDay: { _ in }
    )
    .dynamicTypeSize(.large ... .accessibility5)
}
#endif

// MARK: - CalendarView

import SwiftUI
import AtegalCore

struct CalendarView: View {
    
    @Bindable
    var viewModel: CalendarViewModel
    
    let onOpenDay: (Int) -> Void
        
    @State
    var notification: InAppNotificationEvent?
    
    var body: some View {
        contentView
            .showInAppNotification($notification)
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 38) {
                nextEventsView
                activitiesView
            }
            .padding(.vertical, 16)
        }
    }
    
    @ViewBuilder
    private var activitiesView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("calendar-activity-title")
                .primaryTitle()
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.calendar.weekdays, id: \.weekday) { day in
                    Button {
                        onOpenDay(day.weekday)
                    } label: {
                        Text(day.title)
                            .font(.body.weight(.medium))
                            .foregroundStyle(ColorsPalette.textPrimary)
                            .multilineTextAlignment(.leading)
                            .padding(.trailing, 32)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .chevronOverlay()
                            .padding(16)
                            .contentRectangleShape()
                            .combinedAccessibility()
                    }
                    .buttonStyle(.borderless)
                    .ategalCornerBackground()
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var nextEventsView: some View {
        if !viewModel.eventDays.isEmpty {
            VStack(alignment: .leading, spacing: 24) {
                Text("calendar-events-title")
                    .primaryTitle()
                    .padding(.horizontal, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.eventDays, id: \.self) { date in
                            cell(for: date)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                VStack(spacing: 8) {
                    ForEach(viewModel.eventsForSelectedDate) {
                        cell(for: $0)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 16)
        }
    }
    
    @ViewBuilder
    private func cell(for date: Date) -> some View {
        let selected = viewModel.calendar.isDate(
            date, inSameDayAs: viewModel.selectedDate
        )
        Button {
            withAnimation(.smooth(duration: 0.3)) {
                viewModel.selectedDate = date
            }
        } label: {
            VStack(spacing: 6) {
                Text(date.formatted(.dateTime.month()))
                    .font(.headline)
                    .foregroundStyle(selected
                                     ? ColorsPalette.background
                                     : ColorsPalette.textSecondary
                    )
                
                Text(date.formatted(.dateTime.day()))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(selected
                                     ? ColorsPalette.background
                                     : ColorsPalette.textPrimary
                    )
                
                Text(date.formatted(.dateTime.weekday()))
                    .font(.headline)
                    .foregroundStyle(selected ? ColorsPalette.background.opacity(0.9) : ColorsPalette.textSecondary)
            }
            .padding(16)
            .frame(minWidth: 76)
        }
        .cornerBackground(
            selected
            ? ColorsPalette.primary
            : ColorsPalette.backgroundSecondary
        )
    }
    
    @ViewBuilder
    private func cell(for event: Event) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            label(for: event)
            addToCalendarButton(for: event)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ategalCornerBackground()
    }

    @ViewBuilder
    private func addToCalendarButton(for event: Event) -> some View {
        #if canImport(Darwin)
        AsyncButton {
            if await LinkHelper.shared.addToAppleCalendar(event: event) {
                notification = .message(
                    String(localized: "add-event-calendar-title"),
                    message: String(localized: "add-event-calendar-subtitle"),
                    icon: Image(systemName: "checkmark.circle.fill"),
                    backgroundColor: ColorsPalette.primary
                )
            } else {
                notification = .error(
                    String(localized: "error"),
                    message: String(localized: "error-message")
                )
            }
        } label: {
            addToCalendarLabel
        }
        #else
        Link(destination: LinkHelper.shared.androidCalendar(for: event)) {
            addToCalendarLabel
        }
        #endif
    }

    @ViewBuilder
    private var addToCalendarLabel: some View {
        Label("add-event-calendar-action", systemImage: "calendar")
            .font(.body.weight(.semibold))
            .foregroundStyle(ColorsPalette.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }
    
    @ViewBuilder
    private func label(for event: Event) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(ColorsPalette.textPrimary)
                .lineLimit(2)
            
            Text(event.startDate.formatted())
                .font(.subheadline.weight(.regular))
                .foregroundStyle(ColorsPalette.textSecondary)
            
            if let description = event.description, !description.isEmpty {
                Text(description)
                    .font(.subheadline.weight(.regular))
                    .foregroundStyle(ColorsPalette.textSecondary)
            }
        }
        .multilineTextAlignment(.leading)
    }
}

// MARK: - CalendarAsyncView

struct CalendarAsyncView: View {
    
    let onOpenDay: (Int) -> Void
    
    let wpApiClient: WPAPIClient
    let centers: [Center]
    var initialDate: Date? = nil
    
    var body: some View {
        AsyncView(id: initialDate) {
            try await CalendarViewModel(
                wpApiClient: wpApiClient,
                centers: centers,
                initialDate: initialDate
            )
        } content: {
            CalendarView(
                viewModel: $0,
                onOpenDay: onOpenDay
            )
        }
        .tint(ColorsPalette.primary)
        .background(ColorsPalette.background)
        .navigationTitle("calendar-title")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - CalendarViewModel

@Observable
@MainActor
class CalendarViewModel {
    
    @ObservationIgnored
    var calendar: Calendar
    
    @ObservationIgnored
    let centers: [Center]
    
    var events: [Event]
    
    var selectedDate: Date
    
    init(wpApiClient: WPAPIClient, centers: [Center], initialDate: Date? = nil) async throws {
        self.calendar = .ategal
        self.centers = centers
        let events = await wpApiClient.fetchCalendarEvents()
        let today = calendar.startOfDay(for: Date())
        let upcomingEvents = events.filter {
            $0.startDate >= today
        }
        self.events = upcomingEvents
        self.selectedDate = initialDate ?? upcomingEvents
            .sorted { $0.startDate < $1.startDate }
            .first?.startDate ?? Date()
    }
    
    var eventDays: [Date] {
        Set(events.map { calendar.startOfDay(for: $0.startDate) }).sorted()
    }
    
    var eventsForSelectedDate: [Event] {
        events.filter {
            calendar.isDate($0.startDate, inSameDayAs: selectedDate)
        }
    }
    
    /// For Preview
    static func mock() -> CalendarViewModel {
        .init()
    }
    private init() {
        self.calendar = Calendar.current
        self.events = MockCalendar.events
        self.selectedDate = Date()
        self.centers = []
    }
}

// MARK: - Extensions

private extension Calendar {
    
    static let ategal: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "gl_ES")
        calendar.firstWeekday = 2
        return calendar
    }()

    var weekdays: [(weekday: Int, title: String)] {
        let startIndex = firstWeekday - 1
        let items = weekdaySymbols.shifted(startingAt: startIndex)
        return items.enumerated().map { offset, title in
            let weekday = ((startIndex + offset) % 7)
            return (weekday: weekday, title: title.capitalized)
        }
    }
}

private extension Array {
    
    func shifted(startingAt i: Int) -> [Element] {
        guard !isEmpty else { return [] }
        let idx = ((i % count) + count) % count
        return Array(self[idx...] + self[..<idx])
    }
}

// MARK: - Mocks

private enum MockCalendar {
    
    static let events: [Event] = [
        Event(
            id: UUID().uuidString,
            title: "Clase de Fotografía",
            startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            description: "Aprende técnicas de fotografía urbana."
        ),
        Event(
            id: UUID().uuidString,
            title: "Visita al Museo",
            startDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            description: "Exploramos arte contemporáneo gallego."
        ),
        Event(
            id: UUID().uuidString,
            title: "Taller de Cocina",
            startDate: Calendar.current.date(byAdding: .day, value: 4, to: Date())!,
            description: "Cocinamos platos típicos de Galicia."
        ),
        Event(
            id: UUID().uuidString,
            title: "Excursión al monte",
            startDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            description: "Ruta sencilla y picnic al aire libre."
        )
    ]
}
