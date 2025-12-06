//
//  Created by Michele Restuccia on 11/11/25.
//

import SwiftUI

struct AsyncButton<Label: View>: View {
    
    let action: AsyncVoidHandler
    let label: () -> Label
    let completion: Completion
    enum Completion {
        case none
        case confirmation(
            title: LocalizedStringKey,
            subtitle: LocalizedStringKey? = nil,
            isOK: Bool
        )
    }
    
    init(action: @escaping AsyncVoidHandler, label: @escaping () -> Label, completion: Completion = .none) {
        self.action = action
        self.label = label
        self.completion = completion
    }
    
    @State
    var isLoading: Bool = false
    
    @State
    var taskError: Error? = nil
    
    @State
    var showSuccessToast: Bool = false

    var body: some View {
        Button {
            triggerAsyncAction()
        } label: {
            label()
                .opacity(isLoading ? 0 : 1)
        }
        .disabled(isLoading)
        .overlay(spinnerOverlay, alignment: .center)
        .errorToast(error: $taskError)
        .successToast(
            isPresented: $showSuccessToast,
            isOK: completion.tuple.isOK,
            title: completion.tuple.title,
            subtitle: completion.tuple.subtite
        )
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var spinnerOverlay: some View {
        if isLoading {
            ProgressView()
        }
    }
    
    // MARK: Actions
    
    private func triggerAsyncAction() {
        isLoading = true
        Task {
            do {
                await resetToastStatesIfNeeded()
                try await action()
                if case .confirmation = completion {
                    showSuccessToast = true
                }
            } catch {
                taskError = error
            }
            isLoading = false
        }
    }
    
    private func resetToastStatesIfNeeded() async {
        let shouldResetToastStates = taskError != nil || showSuccessToast
        if shouldResetToastStates {
            taskError = nil
            showSuccessToast = false
            /// Wait for the animation to complete before starting the action
            try? await Task.sleep(for: .milliseconds(300))
        }
    }
}

// MARK: Extensions

private extension AsyncButton.Completion {
    
    var tuple: (title: LocalizedStringKey, subtite: LocalizedStringKey?, isOK: Bool) {
        switch self {
        case let .confirmation(title, subtitle, isOK): return (title, subtitle, isOK)
        case .none: return ("accept", nil, false)
        }
    }
}
