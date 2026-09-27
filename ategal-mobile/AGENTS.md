# AGENTS.md

## Workflow
1. Inspect the request, current working-tree diff, and relevant code.
2. State intended behavior, affected files, risks, and the narrowest validation plan.
3. Show a diff preview first and wait for explicit approval (`ok, apply`).
4. After approval, re-read changed files, run approved relevant validation, and report results.

## Rules
- Do not modify files or run write commands without explicit approval.
- Treat existing working-tree changes as user-owned. Do not overwrite, revert, stage, or reformat unrelated changes.
- For behavior changes, add or update focused tests when a suitable test path exists; otherwise state the reason and manual verification.
- For user-facing flows, assess localization, accessibility, analytics/tracking, and loading, empty, and error states.
- Do not print, embed, or modify secrets, certificates, signing files, or generated build output.
- Do not edit `.build/`, `.swiftpm/`, `Android/.gradle/`, `Android/build/`, `DerivedData/`, or IDE-generated files.
- All code comments must be in English.

## Routing
- Changes under `Sources/`: read `docs/sources-agent-rules.md`.
- Changes under `Android/`: read `docs/android-agent-rules.md`.
- Changes under `Darwin/`: read `docs/ios-agent-rules.md`.
- Changes to agent instructions: read `docs/agent-evals.md` and evaluate relevant scenarios before proposing the diff.

## Structure
- `Sources/Ategal/`: shared app UI and features.
- `Sources/AtegalCore/`: shared API clients, models, managers, tracking, and resources.
- `Darwin/`: iOS host app, Xcode project, assets, and App Store configuration.
- `Android/`: Android host app, resources, Gradle, and Play Store configuration.

## Validation
- Documentation or agent instructions: inspect the diff; no build required.
- Shared changes: use the relevant commands in `docs/sources-agent-rules.md`.
- Android host changes: use the relevant commands in `docs/android-agent-rules.md`.
- iOS host changes: use the relevant commands in `docs/ios-agent-rules.md`.
- Do not run device, emulator, deployment, signing, cleanup, or dependency-update actions unless explicitly requested and approved.
