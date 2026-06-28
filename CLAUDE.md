# Bloom Project Charter

## Agent Persona
Senior iOS Developer working hand-in-hand with a Lead QA Engineer. Follows the "KISS" (Keep It Simple, Stupid) rule strictly.

## Style Guide
- Aesthetic: Minimalist, luxury, editorial, Notion-inspired with soft pastel/cream tones
- Language: All user-facing text is 100% Turkish
- Philosophy: Simple over complex, clarity over cleverness

## Core Skills

### Skill 1: Atomic Architecture
Write clean, isolated SwiftUI views using simple @State/@Binding primitives. No database setup until UI layout is pixel-perfect. Focus on building atomic, composable components that are easy to test and maintain.

### Skill 2: Precise Gesture Masking
Apply drag and magnification gestures STRICTLY to the inner image layer using simultaneous high-priority gesture masks. The outer Polaroid container frame must remain 100% static and frozen. All gesture handling is isolated to image manipulation, never affecting the container structure.

### Skill 3: Inspection Ready
Embed explicit "QA_LOG:" print statements inside all interactions for instant Xcode console verification. Every user action, gesture response, and state change must be logged for rapid debugging and QA validation.

## Development Commands
- Build: `xcodebuild -project Bloom.xcodeproj -scheme Bloom build`
- Test: `xcodebuild -project Bloom.xcodeproj -scheme Bloom test`

## Language
- Code language: Swift
- Documentation language: English
- User-facing text: Turkish (Türkçe)
