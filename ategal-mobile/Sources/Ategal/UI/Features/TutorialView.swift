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

    @Binding
    var isPresented: Bool

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
        .background(ColorsPalette.background)
    }
}

// MARK: - TutorialStepView

struct TutorialStepView: View {

    let step: TutorialStep
    let onFinish: () -> Void

    var body: some View {
        ScrollView {
            stepView
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .background(ColorsPalette.background)
        .navigationTitle(
            step == .welcome ? "push-tutorial-navigation-title".localized : ""
        )
        .navigationBarTitleDisplayMode(.inline)
        .actionView { actionView }
        .background(ColorsPalette.background)
    }
    
    @ViewBuilder
    private var stepView: some View {
        VStack(spacing: 16) {
            Text(step.progressTitle)
                .font(.headline)
                .foregroundStyle(ColorsPalette.textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            VStack(spacing: 16) {
                if let symbol = step.symbol {
                    Image(systemName: symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(ColorsPalette.primary)
                        .accessibilityHidden(true)
                } else {
                    Image(ategal: "logo-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .accessibilityHidden(true)
                }
                Text(step.title)
                    .font(.title.bold())
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)

            ForEach(step.messageBlocks, id: \.self) { block in
                switch block {
                case .paragraph(let text):
                    tutorialMessageText(text)
                case .bulletList(let items):
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(items, id: \.self) { item in
                            HStack(alignment: .top, spacing: 8) {
                                Text(verbatim: "•")
                                    .accessibilityHidden(true)
                                tutorialMessageText(item)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func tutorialMessageText(_ text: String) -> some View {
        Text(LocalizedStringKey(text))
            .font(.title2)
            .lineSpacing(4)
            .foregroundStyle(ColorsPalette.textSecondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
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
            .ategalCornerPrimaryBackground()
            .foregroundStyle(ColorsPalette.textTertiary)
    }
}

enum TutorialMessageBlock: Hashable {
    case paragraph(String)
    case bulletList([String])
}

enum TutorialStep: Hashable {
    case welcome
    case socialLogin
    case permission
    case cities
    case inbox

    var progressTitle: LocalizedStringKey {
        switch self {
        case .welcome: "push-tutorial-progress-1"
        case .socialLogin: "push-tutorial-progress-2"
        case .permission: "push-tutorial-progress-3"
        case .cities: "push-tutorial-progress-4"
        case .inbox: "push-tutorial-progress-5"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .welcome: "auth-title"
        case .socialLogin: "push-tutorial-social-title"
        case .permission: "push-tutorial-permission-title"
        case .cities: "push-tutorial-cities-title"
        case .inbox: "push-tutorial-inbox-title"
        }
    }

    var messageBlocks: [TutorialMessageBlock] {
        switch self {
        case .welcome: [
            .paragraph("push-tutorial-welcome-message-1".localized),
            .bulletList([
                "push-tutorial-welcome-message-2".localized,
                "push-tutorial-welcome-message-2-notifications".localized,
                "push-tutorial-welcome-message-2-cities".localized
            ]),
            .paragraph("push-tutorial-welcome-message-3".localized)
        ]
        #if os(Android)
        case .socialLogin: [
            .paragraph("push-tutorial-social-android-message-1".localized),
            .paragraph("push-tutorial-social-android-message-2".localized),
            .paragraph("push-tutorial-social-message-3".localized)
        ]
        #else
        case .socialLogin: [
            .paragraph("push-tutorial-social-message-1".localized),
            .paragraph("push-tutorial-social-message-2".localized),
            .paragraph("push-tutorial-social-message-3".localized)
        ]
        #endif
        case .permission: [
            .paragraph("push-tutorial-permission-message-1".localized),
            .paragraph("push-tutorial-permission-message-2".localized),
            .paragraph("push-tutorial-permission-message-3".localized)
        ]
        case .cities: [
            .paragraph("push-tutorial-cities-message".localized)
        ]
        case .inbox: [
            .paragraph("push-tutorial-inbox-message".localized)
        ]
        }
    }

    var symbol: String? {
        switch self {
        case .welcome: nil
        case .socialLogin: "person.crop.circle"
        case .permission: "bell"
        case .cities: "checkmark.circle"
        case .inbox: "envelope"
        }
    }

    var next: TutorialStep? {
        switch self {
        case .welcome: .socialLogin
        case .socialLogin: .permission
        case .permission: .cities
        case .cities: .inbox
        case .inbox: nil
        }
    }
}
