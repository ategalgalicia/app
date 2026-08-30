import SwiftUI
import AtegalCore
import RStudioKit

// MARK: - DeeplinkView

struct DeeplinkView: View {
    
    @Binding
    var navigationPath: [HomeRoute]

    let payload: DeeplinkPayload
    let centers: [Center]

    var body: some View {
        AsyncView {
            try await Deeplink.resolve(payload: payload)
        } content: {
            switch $0.action {
            case .search(let query):
                SearchListView(
                    navigationPath: $navigationPath,
                    source: .activitiesFilteredByText(query),
                    centers: centers
                )
            }
        }
    }
}
