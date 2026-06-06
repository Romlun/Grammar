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
- PROJECT_STATE.md created
- GitHub SSH connection configured

## In-Flight
- [ ] Create Xcode multiplatform project and push to repo

## Up Next (Phase 1 — Week 1)
- [ ] Action + StyleContext enums
- [ ] Basic UI: text input + action picker + result area
- [ ] ClaudeService.swift with streaming
- [ ] KeychainService.swift
- [ ] Settings screen (API key input)

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
