//
//  Created by Michele Restuccia on 11/11/25.
//

import SwiftUI
import AtegalCore

#if canImport(Darwin)

// MARK: Previews

#Preview {
    CalendarView(dataSource: .mock())
}
#endif

// MARK: CalendarView

import SwiftUI
import AtegalCore

struct CalendarView: View {
    
    @Bindable
    var dataSource: CalendarDataSource
    
    @State
    var showSuccess = false
        
    @State
    var errorMessage: String?
    
    @SwiftUI.Environment(\.openURL)
    var openURL
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 8),
        count: 1
    )
    
    var body: some View {
        contentView
            .tint(ColorsPalette.primary)
            .background(ColorsPalette.background)
            .navigationTitle("tab-calendar")
            .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                horizontalCalendar
                eventList
            }
        }
    }
    
    @ViewBuilder
    private var horizontalCalendar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(dataSource.eventDays, id: \.self) { date in
                    cell(for: date)
                }
            }
            .padding(16)
        }
    }
    
    @ViewBuilder
    private func cell(for date: Date) -> some View {
        let selected = dataSource.calendar.isDate(date, inSameDayAs: dataSource.selectedDate)
        
        Button {
            withAnimation(.smooth(duration: 0.3)) {
                dataSource.selectedDate = date
            }
        } label: {
            VStack(spacing: 6) {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(selected ? ColorsPalette.background : ColorsPalette.textSecondary)
                
                Text(verbatim: "\(dataSource.calendar.component(.day, from: date))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(selected ? ColorsPalette.background : ColorsPalette.textPrimary)
                
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption2)
                    .foregroundStyle(selected ? ColorsPalette.background.opacity(0.9) : ColorsPalette.textSecondary)
                
                if let count = dataSource.eventCounts[date], count > 1 {
                    Text(verbatim: "\(count)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(ColorsPalette.background.opacity(selected ? 0.2 : 1.0))
                        .clipShape(Capsule())
                        .foregroundStyle(selected ? ColorsPalette.background : ColorsPalette.textPrimary)
                }
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
    private var eventList: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(dataSource.eventsForSelectedDate) {
                cell(for: $0)
            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func cell(for event: Event) -> some View {
        #if os(Android)
        Link(destination: CalendarService.shared.url(for: event)) {
            label(for: event)
        }
        .cornerBackground()
        #else
        AsyncButton(
            action: {
                try await CalendarService.shared.addToCalendar(event: event)
            },
            label: {
                label(for: event)
            },
            completion: .confirmation(
                title: "add-event-calendar-title",
                subtitle: "add-event-calendar-subtitle"
            )
        )
        .cornerBackground()
        #endif
    }
    
    @ViewBuilder
    private func label(for event: Event) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(ColorsPalette.textPrimary)
                .lineLimit(2)
            
            Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                .font(.footnote)
                .foregroundStyle(ColorsPalette.textSecondary)
            
            if let description = event.description, !description.isEmpty {
                Text(description)
                    .font(.caption)
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
    
    let apiClient: AtegalAPIClient
    
    var body: some View {
        AsyncView {
            try await CalendarDataSource(apiClient: apiClient)
        } content: {
            CalendarView(dataSource: $0)
        }
    }
}

// MARK: CalendarDataSource

@Observable
@MainActor
class CalendarDataSource {
    
    let calendar: Calendar
    let events: [Event]
    var selectedDate: Date
    
    init(apiClient: AtegalAPIClient) async throws {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        self.calendar = calendar
        self.events = try await apiClient.fetchCalendarEvents()
        self.selectedDate = events.sorted { $0.startDate < $1.startDate }.first?.startDate ?? Date()
    }
    
    var eventDays: [Date] {
        Set(events.map { calendar.startOfDay(for: $0.startDate) }).sorted()
    }
    
    var eventCounts: [Date: Int] {
        Dictionary(
            grouping: events.map { calendar.startOfDay(for: $0.startDate) }, by: { $0 }
        )
        .mapValues { $0.count }
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
        self.events = MockCalendar.events
        self.calendar = Calendar.current
        self.selectedDate = Date()
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
