//
//  Created by Michele Restuccia on 23/10/25.
//

import SwiftUI

struct AsyncView<Data, Content: View>: View {
    let load: () async throws -> Data

    private let content: (Data) -> Content

    @State
    var data: Data?
    
    @State
    var error: Error?

    init(
        load: @escaping () async throws -> Data,
        @ViewBuilder content: @escaping (Data) -> Content
    ) {
        self.load = load
        self.content = content
    }

    var body: some View {
        VStack {
            if let data {
                content(data)
            } else if let error {
                ErrorView(error: error) { reload() }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            }
        }
        .task {
            await loadData()
        }
    }

    // MARK: Actions

    @MainActor
    private func loadData() async {
        guard data == nil else { return }
        do {
            let result = try await load()
            self.data = result
        } catch {
            self.error = error
        }
    }

    private func reload() {
        data = nil
        error = nil
        Task { await loadData() }
    }
}
