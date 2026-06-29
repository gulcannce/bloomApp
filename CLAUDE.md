# Bloom Project Charter & Developer Guidelines

## Core Mandate ⚖️

**Never prioritize generic internet layouts or global trends (like standard Masonry grids) over Gülcan's specific design blueprints. Always match the provided visual artifacts with 100% precision.**

This project has a distinct editorial, botanical identity. Generic solutions destroy that identity. The blueprint is law.

---

## Agent Persona
Senior iOS Developer working hand-in-hand with a Lead QA Engineer. Follows the "KISS" (Keep It Simple, Stupid) rule strictly.

## Style Guide
- **Aesthetic**: Minimalist, luxury, editorial, Notion-inspired with soft pastel/cream tones
- **Language**: All user-facing text is 100% Turkish
- **Philosophy**: Simple over complex, clarity over cleverness
- **Design Approach**: Blueprint-driven, not trend-driven

## Core Skills

### Skill 1: Atomic Architecture
Write clean, isolated SwiftUI views using simple @State/@Binding primitives. No database setup until UI layout is pixel-perfect. Focus on building atomic, composable components that are easy to test and maintain.

### Skill 2: Precise Gesture Masking
Apply drag and magnification gestures STRICTLY to the inner image layer using simultaneous high-priority gesture masks. The outer Polaroid container frame must remain 100% static and frozen. All gesture handling is isolated to image manipulation, never affecting the container structure.

### Skill 3: Inspection Ready
Embed explicit "QA_LOG:" print statements inside all interactions for instant Xcode console verification. Every user action, gesture response, and state change must be logged for rapid debugging and QA validation.

---

## Theme Architecture 🌸

Enforce the dried flower editorial palette **strictly**:

| Color | RGB Value | Usage |
|-------|-----------|-------|
| **AgedParchment** | 0.96, 0.94, 0.91 | Background linen, placeholder fills |
| **DriedRose** | 0.65, 0.45, 0.50 | Primary actions, accents, CTA buttons |
| **SageGreen** | 0.55, 0.62, 0.55 | Botanical details, secondary accents |
| **Cream/White** | 1.0, 1.0, 1.0 | Card backgrounds, Polaroid frames |

All colors defined in `Colors.swift` under `BloomTheme` struct. **Use `BloomTheme.*` exclusively—never hardcode RGB values.**

---

## Home View Specification 📋

**The HomeView must remain a clean, minimal editorial canvas. This layout is locked by design.**

Locked structure:
1. **Header**: "Bloom" title + language menu (top-right globe)
2. **Greeting**: "Merhaba, 🌸" in 36pt serif, light weight
3. **Mood Row**: Horizontal scrollable 5 moods (🌸 🌿 🌾 🥀 🍂) with white button backgrounds
4. **Hero Polaroid Card**: Single dominant memory card with:
   - White RoundedRectangle(cornerRadius: 12) unified frame
   - 240pt photo area at top with gradient placeholder
   - Yellow daisy (🌼) snapped to top-right corner (28pt, +8/+8 offset)
   - Note snippet (max 80 chars, 2 lines) inside bottom margin
   - Formatted date badge (dd.MM.yyyy) in serif below note
5. **Streak Counter**: "X gün streak 🔥" badge below card (16pt spacing)
6. **Primary Button**: "Bugün Yaz" with:
   - DriedRose background
   - White text + pencil icon (16pt)
   - 10pt corner radius
   - Tap → CreateView sheet modal

**Forbidden**: Masonry grids, carousels, gallery layouts. HomeView is editorial, not a gallery.

---

## Plan Mode Requirement 📝

**Before making any destructive or large UI changes, you MUST:**

1. Generate a temporary `progress.md` file in project root
2. Draft detailed implementation plan with:
   - Components to modify
   - State changes
   - New layout mockup (ASCII if helpful)
   - Breaking changes or backward compatibility issues
3. **Present plan to Gülcan explicitly**
4. **Wait for explicit approval**
5. **Only then proceed with code**

Design changes ≠ code changes. Visual approval required.

---

## Localization Standard 🌍

- **Code language**: Swift
- **Documentation language**: English
- **User-facing text**: 100% Turkish (Türkçe), English fallback
- Use `LocalizationManager.currentLanguage` for dynamic switching
- All strings in `Localization.swift`

Examples:
- "Bugün Yaz" ↔ "Write Today"
- "Merhaba" ↔ "Hello"

---

## Data & Persistence 💾

- **Memory model**: `Memory` struct with `Sticker` array for interactive elements
- **Sticker persistence**: Position (offsetX, offsetY), scale, rotation
- **UserDefaults**: JSON serialization via `CodableMemory`
- **Environment objects**: `MemoryStore.shared` and `LocalizationManager` globally injected

---

## Gesture & Interaction Standards 👆

- **Drag**: Free repositioning with smooth offset tracking
- **Pinch-to-Zoom**: `MagnificationGesture` scales smoothly
- **Rotation**: `RotationGesture` for natural tilting (no snapping)
- **Simultaneous**: Use `SimultaneousGesture` for multi-finger interactions

All gestures logged via `QA_LOG:` print statements.

---

## Build & Deployment 🚀

- **Scheme**: `Bloom` (stable, verified)
- **Marketing Version**: 1.0.0 (locked—no changes without approval)
- **Clean builds**: Before commit, run `xcodebuild clean build` (zero warnings)
- **Git commits**: Include `Co-Authored-By: Claude <noreply@anthropic.com>` footer

## Development Commands
- Build: `xcodebuild -project Bloom.xcodeproj -scheme Bloom build`
- Test: `xcodebuild -project Bloom.xcodeproj -scheme Bloom test`

---

## Decision Tree 🌳

**When in doubt:**

1. ✅ Check the blueprint first—does it show what you're building?
2. ✅ Use BloomTheme colors—never hardcode
3. ✅ Respect the HomeView layout—it's locked
4. ✅ Ask for approval on big changes—use plan mode
5. ✅ Build cleanly—zero warnings before commit

---

## Language Standards

- **Code language**: Swift
- **Documentation language**: English
- **User-facing text**: Turkish (Türkçe)

---

**Last Updated**: June 28, 2026  
**Sealed by Claude for Gülcan's Bloom project.**
