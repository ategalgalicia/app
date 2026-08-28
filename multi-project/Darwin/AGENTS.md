# iOS Host Rules

## Architecture
- Preserve the existing Xcode and SwiftUI host architecture.
- Keep iOS-only assets, entitlements, configuration, and native integrations within `Darwin/`.
- Do not move shared behavior into the iOS host when it belongs in `Sources/`.

## User-Facing UI
- Preserve localization, accessibility labels, traits, focus order, Dynamic Type, contrast, and reduced-motion behavior when relevant.
- For changed flows, assess loading, content, empty, and error states.

## Validation
- iOS host changes: `cd Darwin && fastlane assemble` only when the required signing environment is available and validation is requested.
- Do not inject signing credentials, deploy, or clear DerivedData unless explicitly requested and approved.

