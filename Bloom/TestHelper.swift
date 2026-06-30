import Foundation

// MARK: - Unit Test Suite (Documentation + Verification Functions)

struct BloomTestSuite {

    /// Test memory creation and storage
    static func testAddMemory() -> Bool {
        let store = MemoryStore.shared
        let initialCount = store.memories.count

        let testMemory = Memory(
            image: nil,
            note: "Test memory",
            emoji: "🌸",
            date: Date(),
            stickers: []
        )

        store.addMemory(testMemory)
        let passed = store.memories.count == initialCount + 1

        print("✓ testAddMemory: \(passed ? "PASS" : "FAIL")")
        return passed
    }

    /// Test streak calculation with consecutive days
    static func testLongestStreakCalculation() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var testMemories: [Memory] = []

        // Create 5 consecutive days of memories
        for i in 0..<5 {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let memory = Memory(
                image: nil,
                note: "Day \(i)",
                emoji: "🌸",
                date: date,
                stickers: []
            )
            testMemories.append(memory)
        }

        let streak = calculateLongestStreak(memories: testMemories)
        let passed = streak == 5

        print("✓ testLongestStreakCalculation: \(passed ? "PASS" : "FAIL") (streak=\(streak))")
        return passed
    }

    /// Test date formatting for Turkish locale
    static func testDateFormatting() -> Bool {
        let formatter = DateFormatter()
        let testDate = Date()

        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")

        let formatted = formatter.string(from: testDate)
        let passed = !formatted.isEmpty

        print("✓ testDateFormatting: \(passed ? "PASS" : "FAIL") (date=\(formatted))")
        return passed
    }

    /// Test search/filter by note content
    static func testSearchByNote() -> Bool {
        let memories = [
            Memory(image: nil, note: "Coffee morning", emoji: "🌸", date: Date(), stickers: []),
            Memory(image: nil, note: "Afternoon walk", emoji: "🌿", date: Date(), stickers: []),
            Memory(image: nil, note: "Evening coffee", emoji: "🌾", date: Date(), stickers: [])
        ]

        let filtered = memories.filter { memory in
            memory.note.localizedCaseInsensitiveContains("coffee")
        }

        let passed = filtered.count == 2

        print("✓ testSearchByNote: \(passed ? "PASS" : "FAIL") (found=\(filtered.count))")
        return passed
    }

    /// Test search/filter by emoji
    static func testSearchByEmoji() -> Bool {
        let memories = [
            Memory(image: nil, note: "Happy day", emoji: "🌸", date: Date(), stickers: []),
            Memory(image: nil, note: "Good walk", emoji: "🌿", date: Date(), stickers: []),
            Memory(image: nil, note: "Nice evening", emoji: "🌸", date: Date(), stickers: [])
        ]

        let filtered = memories.filter { memory in
            memory.emoji.contains("🌸")
        }

        let passed = filtered.count == 2

        print("✓ testSearchByEmoji: \(passed ? "PASS" : "FAIL") (found=\(filtered.count))")
        return passed
    }

    /// Test sticker creation with default values
    static func testStickerDefaults() -> Bool {
        let sticker = Sticker(name: "test")

        let passed = sticker.offsetX == 0 &&
                    sticker.offsetY == 0 &&
                    sticker.scale == 1.0 &&
                    sticker.rotation == 0

        print("✓ testStickerDefaults: \(passed ? "PASS" : "FAIL")")
        return passed
    }

    /// Test sticker custom values
    static func testStickerCustomValues() -> Bool {
        let sticker = Sticker(
            name: "custom",
            offsetX: 10,
            offsetY: 20,
            scale: 1.5,
            rotation: 45
        )

        let passed = sticker.offsetX == 10 &&
                    sticker.offsetY == 20 &&
                    sticker.scale == 1.5 &&
                    sticker.rotation == 45

        print("✓ testStickerCustomValues: \(passed ? "PASS" : "FAIL")")
        return passed
    }

    /// Test same day date comparison
    static func testSameDayComparison() -> Bool {
        let calendar = Calendar.current
        let date1 = Date()
        let date2 = calendar.date(byAdding: .hour, value: 5, to: date1) ?? date1

        let isSameDay = calendar.isDate(date1, inSameDayAs: date2)
        let passed = isSameDay

        print("✓ testSameDayComparison: \(passed ? "PASS" : "FAIL")")
        return passed
    }

    /// Run all tests
    static func runAllTests() {
        print("\n=== Bloom Unit Test Suite ===\n")

        var results: [Bool] = []
        results.append(testAddMemory())
        results.append(testLongestStreakCalculation())
        results.append(testDateFormatting())
        results.append(testSearchByNote())
        results.append(testSearchByEmoji())
        results.append(testStickerDefaults())
        results.append(testStickerCustomValues())
        results.append(testSameDayComparison())

        let passed = results.filter { $0 }.count
        let total = results.count

        print("\n=== Results ===")
        print("Passed: \(passed)/\(total)")
        print("Status: \(passed == total ? "✅ ALL TESTS PASSED" : "⚠️ SOME TESTS FAILED")\n")
    }

    // MARK: - Helper Functions

    private static func calculateLongestStreak(memories: [Memory]) -> Int {
        guard !memories.isEmpty else { return 0 }

        let calendar = Calendar.current
        let dates = Set(memories.map { calendar.startOfDay(for: $0.date) })
        let sortedDates = dates.sorted(by: >)

        var streak = 1
        var maxStreak = 1

        for i in 0..<(sortedDates.count - 1) {
            let current = sortedDates[i]
            let next = sortedDates[i + 1]
            let daysDifference = calendar.dateComponents([.day], from: next, to: current).day ?? 0

            if daysDifference == 1 {
                streak += 1
                maxStreak = max(maxStreak, streak)
            } else {
                streak = 1
            }
        }

        return maxStreak
    }
}
