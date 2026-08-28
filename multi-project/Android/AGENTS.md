# Android Host Rules

## Architecture
- Preserve the existing Skip Android host boundary. Do not edit generated Kotlin output.
- Keep Android-only resources, manifest configuration, Gradle configuration, and native integrations within `Android/`.
- Preserve deep-link, back-navigation, configuration-change, and process-restoration behavior when the affected flow supports them.

## User-Facing UI
- Preserve meaningful accessibility labels, focus order, touch targets, and contrast.
- Do not hardcode user-facing strings; use the project localization mechanism.
- Preserve loading, content, empty, and error states.

## Validation
- Android host behavior: `cd Android && fastlane test` when relevant.
- Do not run device, emulator, Play deployment, signing, cleanup, or dependency-update actions unless explicitly requested and approved.

