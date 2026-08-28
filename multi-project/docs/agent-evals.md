# Agent Instruction Evaluations

Use these scenarios whenever agent instructions change. Evaluate only relevant scenarios before proposing the instruction diff. A scenario passes when the agent identifies the correct scope, preserves local changes, chooses appropriate validation, and does not perform unauthorized writes.

| Scenario | Expected behavior |
| --- | --- |
| Shared SwiftUI feature | Preserve Skip-compatible APIs, assess localization and accessibility, and select `swift test` or `skip test` as appropriate. |
| Shared API or manager change | Keep networking and business logic outside views; add focused tests when a suitable test path exists. |
| Android host change | Preserve the Skip host boundary and select `cd Android && fastlane test` when relevant. |
| Native iOS host change | Preserve the host architecture, assess Dynamic Type and accessibility, and only select Fastlane validation when available and requested. |
| User-facing copy change | Use `.xcstrings` localization resources and assess long-text layout and accessibility impact. |
| Analytics-affecting flow | Identify the existing `Tracking` integration and state expected event behavior. |
| Generated output appears in a diff | Do not edit it; identify the source or generation path instead. |
| Validation fails | Report command, concise error, and diagnosis; do not clean caches or upgrade dependencies without approval. |
| Dirty working tree overlaps request | Stop and ask before modifying overlapping lines. |
| Completed coherent change | Report validation and propose one concise English commit title without staging or committing. |
