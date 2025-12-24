//
//  Created by Michele Restuccia on 11/11/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)

// MARK: Previews

@available(iOS 18, *)
#Preview {
    @Previewable
    @State
    
    var navigationPath: [HomeRoute] = []
    CalendarView(
        dataSource: .mock(),
        navigationPath: $navigationPath
    )
    .dynamicTypeSize(.large ... .accessibility5)
}
#endif

// MARK: CalendarView

import SwiftUI
import AtegalCore

struct CalendarView: View {
    
    @Bindable
    var dataSource: CalendarDataSource
    
    @Binding
    var navigationPath: [HomeRoute]
    
    @State
    var showSuccess = false
        
    @State
    var errorMessage: String?
    
    @State
    var isOK: Bool = false
    
    @SwiftUI.Environment(\.openURL)
    var openURL
    
    var body: some View {
        contentView
            .tint(ColorsPalette.primary)
            .background(ColorsPalette.background)
            .navigationTitle("calendar-title")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                activitiesView
                nextEventsView
            }
            .padding(.vertical, 16)
        }
    }
    
    @ViewBuilder
    private var activitiesView: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("calendar-activity-title")
                .primaryTitle()
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(dataSource.calendar.weekdays, id: \.weekday) { day in
                    Button {
                        navigationPath.append(.navigateToSearch(
                            .activities(filterDay: day.weekday)
                        ))
                    } label: {
                        HStack(spacing: 16) {
                            Text(day.title)
                                .font(.body.weight(.regular))
                                .foregroundStyle(ColorsPalette.textSecondary)
                                .multilineTextAlignment(.leading)

                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(ColorsPalette.primary)
                                .accessibilityHidden(true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .contentRectangleShape()
                        .combinedAccessibility()
                    }
                    .buttonStyle(.plain)
                    .cornerBackground()
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var nextEventsView: some View {
        if !dataSource.eventDays.isEmpty {
            VStack(alignment: .leading, spacing: 24) {
                Text("calendar-events-title")
                    .primaryTitle()
                    .padding(.horizontal, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(dataSource.eventDays, id: \.self) { date in
                            cell(for: date)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                VStack(spacing: 8) {
                    ForEach(dataSource.eventsForSelectedDate) {
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
        let selected = dataSource.calendar.isDate(
            date, inSameDayAs: dataSource.selectedDate
        )
        Button {
            withAnimation(.smooth(duration: 0.3)) {
                dataSource.selectedDate = date
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
        .cornerBackground(selected
                          ? ColorsPalette.primary
                          : ColorsPalette.cardBackground
        )
    }
    
    @ViewBuilder
    private func cell(for event: Event) -> some View {
        #if canImport(Darwin)
        AsyncButton(
            action: {
                isOK = await LinkManager.shared.addToAppleCalendar(event: event)
            },
            label: {
                label(for: event)
            },
            completion: .confirmation(
                title: "add-event-calendar-title",
                subtitle: "add-event-calendar-subtitle",
                isOK: isOK
            )
        )
        .cornerBackground()
        #else
        Link(destination: LinkManager.shared.androidCalendar(for: event)) {
            label(for: event)
        }
        .cornerBackground()
        #endif
    }
    
    @ViewBuilder
    private func label(for event: Event) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.headline.bold())
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
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: CalendarAsyncView

struct CalendarAsyncView: View {
    
    let wpApiClient: WPAPIClient
    let centers: [Center]
    
    @Binding
    var navigationPath: [HomeRoute]
    
    var body: some View {
        AsyncView {
            try await CalendarDataSource(
                wpApiClient: wpApiClient,
                centers: centers
            )
        } content: {
            CalendarView(
                dataSource: $0,
                navigationPath: $navigationPath
            )
        }
    }
}

// MARK: CalendarDataSource

@Observable
@MainActor
class CalendarDataSource {
    
    @ObservationIgnored
    var calendar: Calendar
    
    @ObservationIgnored
    let centers: [Center]
    
    var events: [Event]
    
    var selectedDate: Date
    
    init(wpApiClient: WPAPIClient, centers: [Center]) async throws {
        self.calendar = .ategal
        self.centers = centers
        let events = await wpApiClient.fetchCalendarEvents()
        self.events = events
        self.selectedDate = events
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
    static func mock() -> CalendarDataSource {
        .init()
    }
    private init() {
        self.calendar = Calendar.current
        self.events = MockCalendar.events
        self.selectedDate = Date()
        self.centers = []
    }
}

// MARK: Extensions

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

// MARK: MockCalendar

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
