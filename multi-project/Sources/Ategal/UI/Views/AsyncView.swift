//
//  Created by Michele Restuccia on 23/10/25.
//

#if os(Android)
import SkipFuseUI
#else
import SwiftUI
#endif

@MainActor
struct AsyncView<Data: Sendable, Content: View>: View {
    let load: @Sendable () async throws -> Data
    private let content: (Data) -> Content

    @State
    var data: Data?
    
    @State
    var error: Error?
    
    @State
    var taskToken = UUID()

    init(
        load: @escaping @Sendable () async throws -> Data,
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
        .task(id: taskToken) {
            await loadData()
        }
    }

    private func loadData() async {
        guard data == nil else { return }
        do {
            let result = try await load()
            await MainActor.run {
                self.error = nil
                self.data = result
            }
        } catch {
            await MainActor.run {
                self.data = nil
                self.error = error
            }
        }
    }

    private func reload() {
        data = nil
        error = nil
        taskToken = UUID()
    }
}
