# WritePro — Project State

## Director
Lite Director — keyboard extension phase

## Platforms
- macOS 14+ (WritePro)
- iOS 26+ (WriteProiOS)

## What's Shipped
- macOS: dark sidebar, Context + Tools, tone pills, streaming rewrites
- macOS: real-time grammar check with red underlines + popover
- macOS: global shortcut Cmd+Shift+W floating panel
- macOS: Email Polish (subject + body), Menu Bar icon
- iOS: full mobile layout — selection sheet, TextEditor, tone pills, Improve button
- iOS: inline result (no separate sheet), Bold & modern design, dark mode
- iOS: Email Polish on iOS (subject + body split)
- iOS: keyboard Done button, Improve pinned above keyboard
- iOS: full-screen fix (launch screen generation)
- iOS: deployment target iOS 26
- History: last 20 rewrites, saved to UserDefaults, restorable — macOS + iOS
- Prompt fixes: no preamble, no meta-responses, "Rewrite this text:" prefix
- Social media prompt: preserves original content, no invented copy
- SidebarSelection label/icon moved to shared file

## Stack
- SwiftUI + AppKit (macOS), SwiftUI (iOS)
- xcodegen (project.yml)
- Claude API via ClaudeService (streaming)
- KeychainService for API key storage
- HistoryService (UserDefaults, max 20 entries)

## Decisions Made
| Decision | Choice | Reason |
|---|---|---|
| iOS deployment target | iOS 26 | Matches device, simplifies design |
| iOS distribution | Free Personal Team | No paid account, 7-day reinstall |
| iOS design | Bold & modern, inline result | User chose |
| History storage | UserDefaults | Simple, sufficient for 20 entries |

## In-Flight / Next Up
- [ ] Keyboard extension (Phase 1 plumbing ready to start)
- [ ] Make Longer tool
- [ ] Share sheet extension
- [ ] iOS app icon
- [ ] Test Email Polish end-to-end on both platforms

## Known Issues
- None currently
