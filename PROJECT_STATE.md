# PROJECT_STATE.md

## App
**Name:** WritePro (working title — rename before any public release)
**Description:** Native SwiftUI app that rewrites and improves text across 7 actions and 6 style contexts, using the Claude API with streaming responses.
**Platforms:** iPhone, iPad, macOS (SwiftUI Multiplatform)

## Director
Lite Director — WritePro v1

## Phase
v1 — setup

## Stack
- SwiftUI Multiplatform (iOS + macOS targets, single codebase)
- Claude API — Haiku for speed/cost; Sonnet option for quality
- No backend — API key stored in iOS Keychain
- Streaming via URLSession async bytes
- No database, no auth, no sync (MVP)

## Repo
https://github.com/Romlun/Grammar

## Decisions Made
| Decision | Choice | Reason |
|---|---|---|
| Platform | SwiftUI Multiplatform | Native Apple feel, one codebase |
| AI backend | Claude API (Haiku / Sonnet) | Best instruction-following, fast streaming |
| Backend server | None (MVP) | Simpler, API key in Keychain |
| Response delivery | Streaming | Feels fast, better UX |
| Monetization | Personal use first | Validate before distributing |
| Priority | Prompt quality | This is the product |

## What's Shipped
- PROJECT_STATE.md + GitHub SSH configured
- Xcode project via xcodegen
- Action + StyleContext enums (7 actions, 6 styles)
- ClaudeService with SSE streaming
- KeychainService (API key storage)
- PromptBuilder (composable action × style prompts)
- Full macOS UI: HSplitView, TextEditor, ActionPickerView, StylePickerView, SettingsView
- Improve button wired to Claude API — streaming results working
- Copy button
- MVP complete and running on Mac

## In-Flight
Nothing — MVP shipped.

## Up Next (Phase 2 — Polish)
- [ ] Try again / regenerate button
- [ ] Word/character count
- [ ] Keyboard shortcut Cmd+Enter to trigger Improve
- [ ] App icon
- [ ] Dark mode polish
- [ ] Fix Grammar as default visible action in picker

## Actions (7)
Fix Grammar · Make Professional · Make Natural · Make Shorter · Make More Polite · Make More Confident · Explain Mistakes

## Style Contexts (6)
Work Email · Healthcare/ECM · Business Communication · Church/Ministry · Immigration/Legal · Everyday Messages

## Out of Scope (MVP)
History, keyboard extension, menu bar app, custom styles, sync, subscription, onboarding

## Notes
- Prompt quality is the core IP — budget ~50% of build time here
- Prompts are composable: base + action layer + style overlay
- Streaming via AsyncThrowingStream over URLSession bytes
- Repo cloned to ~/Developer/Grammar/
