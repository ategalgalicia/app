//
//  Created by Michele Restuccia on 11/11/25.
//

import SwiftUI

extension View {
    
    func successToast(isPresented: Binding<Bool>, title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil) -> some View {
        inlineToast(
            isPresented: isPresented,
            configuration: .init(
                kind: .success(title: title, subtite: subtitle),
                anchor: .top,
                animationAnchor: .bottom
            )
        )
    }
    
    func errorToast(error: Binding<Error?>) -> some View {
        inlineToast(
            isPresented: Binding(
                get: { error.wrappedValue != nil },
                set: { if !$0 { error.wrappedValue = nil } }
            ),
            configuration: .init(
                kind: .error(
                    title: LocalizedStringKey(error.wrappedValue?.localizedDescription ?? "error-message")
                ),
                anchor: .top,
                animationAnchor: .bottom
            )
        )
    }
    
    func inlineToast(isPresented: Binding<Bool>, configuration: InlineToastView.Configuration) -> some View {
        VStack(spacing: 16) {
            if configuration.anchor == .bottom {
                self.frame(maxWidth: .infinity, alignment: configuration.alignment)
            }
            if isPresented.wrappedValue {
                InlineToastView(
                    configuration: configuration,
                    handler: { isPresented.wrappedValue = false }
                )
//                .transition(CustomTransition(anchor: configuration.animationAnchor))
            }
            if configuration.anchor == .top {
                self.frame(maxWidth: .infinity, alignment: configuration.alignment)
            }
        }
        .clipped()
        .animation(.smooth(duration: 0.35, extraBounce: 0), value: isPresented.wrappedValue)
    }
}

// MARK: InlineToastView

struct InlineToastView: View {
    
    struct Configuration {
        enum Kind {
            case success(title: LocalizedStringKey, subtite: LocalizedStringKey?)
            case error(title: LocalizedStringKey)
        }
        let kind: Kind
        
        enum Anchor {
            case top, bottom
        }
        let anchor: Anchor
        let animationAnchor: Anchor
        let alignment: Alignment
        
        init(kind: Kind, anchor: Anchor = .top, animationAnchor: Anchor = .top, alignment: Alignment = .center) {
            self.kind = kind
            self.anchor = anchor
            self.animationAnchor = animationAnchor
            self.alignment = alignment
        }
    }
    let configuration: Configuration
    let handler: VoidHandler
    
    var body: some View {
        Button {
            handler()
        } label: {
            label
        }
    }
    
    // MARK: ViewBuilders
    
    @ViewBuilder
    private var label: some View {
        HStack(spacing: 16) {
            Image(systemName: configuration.kind.icon)
                .font(.title2)
                .foregroundStyle(configuration.kind.tint)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(configuration.kind.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(ColorsPalette.textPrimary)
                    .multilineTextAlignment(.leading)
                
                if let subtitle = configuration.kind.subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(ColorsPalette.textPrimary)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer(minLength: 0)
            
            Image(systemName: "xmark")
                .foregroundStyle(ColorsPalette.textPrimary)
        }
        .padding(16)
        .background {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(configuration.kind.tint)
                    .frame(width: 5)
                
                Rectangle()
                    .fill(configuration.kind.tint.opacity(0.15))
            }
            .cornerRadius(16)
        }
    }
}

// MARK: Extensions

extension InlineToastView.Configuration {
    
    static func success(title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil) -> Self {
        .init(kind: .success(title: title, subtite: subtitle))
    }
    
    static func error(title: LocalizedStringKey) -> Self {
        .init(kind: .error(title: title))
    }
}

private extension InlineToastView.Configuration.Kind {
    
    var tint: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "exclamationmark.circle.fill"
        }
    }
    
    var title: LocalizedStringKey {
        switch self {
        case .success(let title, _): return title
        case .error(let title): return title
        }
    }
    
    var subtitle: LocalizedStringKey? {
        switch self {
        case .success(_, let subtitle): return subtitle
        case .error: return "error-message"
        }
    }
}

//// MARK: CustomTransition
//
//struct CustomTransition: Transition {
//    
//    var anchor: InlineToastView.Configuration.Anchor
//    
//    func body(content: Content, phase: TransitionPhase) -> some View {
//        content
//            .visualEffect { [phase] content, proxy in
//                content
//                    .offset(y: offset(proxy, phase: phase))
//            }
//            .clipped()
//    }
//    
//    nonisolated func offset(_ proxy: GeometryProxy, phase: TransitionPhase) -> CGFloat {
//        let height = proxy.size.height + 16
//        return anchor == .top ? (phase.isIdentity ? 0 : -height) : (phase.isIdentity ? 0 : height)
//    }
//}
