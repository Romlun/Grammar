# PROJECT_STATE.md

## App
**Name:** WritePro (working title)
**Description:** Native macOS SwiftUI writing assistant. Rewrites and improves text using the Claude API. Has real-time grammar checking, a global shortcut floating panel, and a menu bar icon.
**Platform:** macOS 14+ and iOS 17+

## Director
Lite Director — WritePro v1

## Phase
v1 — polish

## Stack
- SwiftUI + AppKit (macOS), xcodegen for project generation
- Claude API — claude-haiku-4-5-20251001, streaming + non-streaming
- API key stored in UserDefaults (no Keychain — avoids permission dialog)
- No backend, no database, no auth
- Repo: ~/Developer/Grammar/

## Architecture

### Sidebar — CONTEXT (rewrites text for a specific register):
Everyday · Professional · Church · Social Media · Personal · Cover Letter

### Sidebar — TOOLS (functional, no rewrite):
Email Polish · Fix Grammar · Make Shorter · Explain Mistakes

### Bottom toolbar — TONE (modifies rewrite output):
Confident · Formal · Warm · Engaging · Casual · Detailed · Direct · Encouraging
(Tone pills visible for Context selections AND Email Polish tool)

### Key files:
- Models: SidebarSelection.swift, Tool.swift, StyleContext.swift, ToneModifier.swift, GrammarMistake.swift
- Services: ClaudeService.swift (streaming), GrammarCheckService.swift (debounced, non-streaming, prompt caching), PanelService.swift, ShortcutService.swift, KeychainService.swift
- Prompts: PromptBuilder.swift — build(selection:tone:input:) returns (system, user)
- Views: ContentView.swift, GrammarTextView.swift (NSViewRepresentable), FloatingPanelView.swift, MistakePopoverView.swift, MenuBarView.swift, SettingsView.swift

### Special behaviors:
- Church context: always uses Biblical style with NLT verses (no tone needed for Biblical — it's always on)
- Email Polish: result must be parsed — starts with "SUBJECT: ..." then body
- Grammar check: debounced 1.5s, toggle in toolbar, disabled by default (UserDefaults key: grammarEnabled)
- Global shortcut: Cmd+Shift+W captures selected text from any app via clipboard, opens floating panel
- Result panel buttons: Try Again, Use as Input, Copy

## What's Shipped
- Full macOS UI: dark sidebar + HSplit editor/result layout
- Context + Tone model (replaced old Action/Style model)
- PromptBuilder with base editor instruction (never responds, always rewrites)
- ClaudeService streaming
- GrammarCheckService with real-time underlines + click-to-popover
- GrammarTextView (NSViewRepresentable with reliable binding.wrappedValue pattern)
- Menu bar icon + MenuBarView
- Global shortcut (Cmd+Shift+W) + FloatingPanelView + PanelService
- ShortcutService with Carbon hotkey + clipboard capture
- App icon (purple rounded square with serif W)
- Try Again + Use as Input + Copy buttons
- Word count in editor
- Email Polish tool (subject + body split result) — just added, not yet tested
- xcodegen project.yml with AppIcon asset
- iOS target (WriteProiOS) — full mobile layout, builds clean
- ContentViewiOS: selection sheet, TextEditor, tone pills, Improve button, result sheet
- Email Polish result on iOS (subject + body split)
- Platform guards: #if os(macOS) on WritePro.swift, ContentView, GrammarTextView, MenuBarView, FloatingPanelView, MistakePopoverView, ShortcutService, PanelService

## In-Flight
- [ ] Test iOS on real device (iPhone RL) — sign & run
- [ ] iOS app icon
- [ ] Test and fix Email Polish feature (macOS + iOS)
- [ ] History (last 20 rewrites, local)

## Decisions Made
| Decision | Choice | Reason |
|---|---|---|
| Platform | macOS first, iOS next | Build and test fast |
| AI backend | Claude Haiku 4.5 | Speed + cost |
| API key storage | UserDefaults | No permission dialogs |
| Grammar check default | Off | User turns on manually |
| Prompt caching | Enabled for grammar check | Cost reduction |
| Style for Church | Always Biblical + NLT | User preference |

## Notes
- Run `xcodegen generate` after any structural file change
- project.yml is in repo root
- Do NOT use Keychain — use UserDefaults for API key (KeychainService.swift now wraps UserDefaults)
- Grammar check is OFF by default (UserDefaults grammarEnabled = false)
- After any commit, always push to origin main
