# Shared Source Rules

## Architecture
- Keep shared UI in `Sources/Ategal/` and shared domain, API, manager, and tracking code in `Sources/AtegalCore/`.
- Prefer Skip-compatible APIs and patterns. Keep platform-specific behavior in `Android/` or `Darwin/`.
- Do not declare `@State` or `@Binding` as `private` in Skip-transpiled SwiftUI.
- Keep networking and business decisions outside views.
- Preserve the existing localization mechanism using `.xcstrings` resources; do not hardcode user-facing text.
- Preserve accessibility identifiers and labels where present.

## Quality
- For a changed user flow, assess loading, content, empty, and error states.
- For UI changes, account for Dynamic Type, long localized text, contrast, and logical focus order.
- For analytics-affecting changes, identify the existing `Tracking` integration and state expected event behavior.

## Validation
- Shared Swift behavior: `swift test`.
- Shared cross-platform behavior: `skip test`.
- Do not run generated-output, emulator, deployment, cleanup, or dependency-update commands unless explicitly requested and approved.

