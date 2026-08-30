import SwiftUI

struct AtegalSearchBarView: View {

    @Binding
    var searchText: String

    let placeholder: String

    init(
        _ searchText: Binding<String>,
        placeholder: String
    ) {
        self._searchText = searchText
        self.placeholder = placeholder
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(ColorsPalette.textSecondary)
                .accessibilityHidden(true)

            TextField(placeholder, text: $searchText)
                .font(.subheadline)
                .foregroundStyle(ColorsPalette.textPrimary)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                #endif
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(ColorsPalette.background)
        .cornerBorder(ColorsPalette.border, radius: 16)
        .frame(maxWidth: .infinity)
    }
}
