//
//  Created by Michele Restuccia on 24/09/26.
//

import SwiftUI
import RStudioKit

#if canImport(Darwin)

// MARK: - Previews

@available(iOS 18, *)
#Preview {
    NavigationStack {
        TutorialView(isPresented: .constant(false))
            .dynamicTypeSize(.large ... .accessibility5)
    }
}
#endif

// MARK: - TutorialView

struct TutorialView: View {

    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            TutorialStepView(step: .welcome) {
                isPresented = false
            }
            .navigationDestination(for: TutorialStep.self) { step in
                TutorialStepView(step: step) {
                    isPresented = false
                }
            }
        }
        .tint(ColorsPalette.primary)
    }
}

// MARK: - TutorialStepView

struct TutorialStepView: View {

    let step: TutorialStep
    let onFinish: () -> Void

    var body: some View {
        ScrollView {
            stepView
        }
        .background(ColorsPalette.background)
        .navigationBarTitleDisplayMode(.inline)
        .actionView { actionView }
    }
    
    @ViewBuilder
    private var stepView: some View {
        VStack(spacing: 16) {
            Text(step.progressTitle)
                .font(.headline)
                .foregroundStyle(ColorsPalette.textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            if let symbol = step.symbol {
                Label {
                    Text(step.title)
                        .fontWeight(.bold)
                        .foregroundStyle(ColorsPalette.textPrimary)
                } icon: {
                    Image(systemName: symbol)
                        .font(.largeTitle)
                        .foregroundStyle(ColorsPalette.primary)
                        .accessibilityHidden(true)
                }
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)
            } else {
                VStack(spacing: 16) {
                    Image("logo-icon", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .accessibilityHidden(true)

                    Text(step.title)
                        .font(.title.bold())
                        .foregroundStyle(ColorsPalette.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }

            ForEach(Array(step.messageBlocks.enumerated()), id: \.offset) { block in
                Text(block.element)
                    .font(.title3)
                    .foregroundStyle(ColorsPalette.textSecondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if let screenshotName = step.screenshotName {
                Image(screenshotName, bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .padding(.top, 16)
                    .frame(maxHeight: 220)
                    .accessibilityHidden(true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var actionView: some View {
        if let next = step.next {
            NavigationLink(value: next) {
                tutorialButtonTitle("push-tutorial-continue")
            }
            .buttonStyle(.plain)
        } else {
            Button {
                onFinish()
            } label: {
                tutorialButtonTitle("push-tutorial-finish")
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func tutorialButtonTitle(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .cornerBackground(ColorsPalette.primary, radius: 14)
            .foregroundStyle(ColorsPalette.textTertiary)
    }
}

enum TutorialStep: Hashable {
    case welcome
    case socialLogin
    case permission
    case cities

    var progressTitle: LocalizedStringKey {
        switch self {
        case .welcome: "push-tutorial-progress-1"
        case .socialLogin: "push-tutorial-progress-2"
        case .permission: "push-tutorial-progress-3"
        case .cities: "push-tutorial-progress-4"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .welcome: "auth-title"
        case .socialLogin: "push-tutorial-social-title"
        case .permission: "push-tutorial-permission-title"
        case .cities: "push-tutorial-cities-title"
        }
    }

    var messageBlocks: [LocalizedStringKey] {
        switch self {
        case .welcome: [
            "push-tutorial-welcome-message-1",
            "push-tutorial-welcome-message-2",
            "push-tutorial-welcome-message-3"
        ]
        #if os(Android)
        case .socialLogin: [
            "push-tutorial-social-android-message-1",
            "push-tutorial-social-android-message-2",
            "push-tutorial-social-message-3"
        ]
        #else
        case .socialLogin: [
            "push-tutorial-social-message-1",
            "push-tutorial-social-message-2",
            "push-tutorial-social-message-3"
        ]
        #endif
        case .permission: [
            "push-tutorial-permission-message-1",
            "push-tutorial-permission-message-2",
            "push-tutorial-permission-message-3"
        ]
        case .cities: ["push-tutorial-cities-message"]
        }
    }

    var screenshotName: String? {
        #if canImport(Darwin)
        switch self {
        case .welcome: nil
        case .socialLogin: "tutorial-login-iphone"
        case .permission: "tutorial-permission-iphone"
        case .cities: "tutorial-cities-iphone"
        }
        #else
        switch self {
        case .welcome: nil
        case .socialLogin: "tutorial-login-android"
        case .permission: "tutorial-permission-android"
        case .cities: "tutorial-cities-android"
        }
        #endif
    }

    var symbol: String? {
        switch self {
        case .welcome: nil
        case .socialLogin: "person.crop.circle"
        case .permission: "bell"
        case .cities: "checkmark.circle"
        }
    }

    var next: TutorialStep? {
        switch self {
        case .welcome: .socialLogin
        case .socialLogin: .permission
        case .permission: .cities
        case .cities: nil
        }
    }
}
