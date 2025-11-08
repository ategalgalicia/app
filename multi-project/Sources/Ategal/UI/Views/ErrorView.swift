//
//  Created by Michele Restuccia on 23/10/25.
//

import SwiftUI

extension SwiftUI.View {
    
    func errorAlert(error: Binding<Error?>) -> some View {
        modifier(ErrorAlertModifier(error: error))
    }
}

// MARK: ErrorView

struct ErrorView: View {
    
    private let error: Error
    private let retryAction: VoidHandler?
    let shouldShowError: Bool
    
    init(error: Error, retryAction: VoidHandler? = nil, shouldShowError: Bool = false) {
        self.error = error
        self.retryAction = retryAction
        self.shouldShowError = shouldShowError
    }
    
    
    var localizedErrorMessage: LocalizedStringKey {
        if shouldShowError {
            return LocalizedStringKey(error.localizedDescription)
        } else {
            return "error-message"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(.orange)
                
                Text(localizedErrorMessage)
                    .font(.subheadline)
            }
            
            if let retryAction {
                Button {
                    retryAction()
                } label: {
                    Text("retry")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: ErrorAlertModifier

struct ErrorAlertModifier: ViewModifier {
    
    @Binding
    var error: Error?

    func body(content: Content) -> some View {
        content
            .alert("error", isPresented: Binding<Bool>(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            )) {
                Button("accept", role: .cancel) {
                    error = nil
                }
            } message: {
                if let error {
                    ErrorView(error: error)
                }
            }
    }
}
