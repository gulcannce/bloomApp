import SwiftUI
import Combine

struct Sticker: Identifiable, Codable {
    let id: UUID
    var name: String
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    var scale: CGFloat = 1.0
    var rotation: Double = 0

    init(name: String, offsetX: CGFloat = 0, offsetY: CGFloat = 0, scale: CGFloat = 1.0, rotation: Double = 0) {
        self.id = UUID()
        self.name = name
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.scale = scale
        self.rotation = rotation
    }
}

struct Memory: Identifiable {
    let id: UUID
    var image: Image?
    var note: String
    let date: Date
    let emoji: String
    var stickers: [Sticker] = []
    var images: [Image] = []

    init(image: Image? = nil, note: String, emoji: String = "🌸", stickers: [Sticker] = []) {
        self.id = UUID()
        self.image = image
        self.note = note
        self.date = Date()
        self.emoji = emoji
        self.stickers = stickers
        self.images = image.map { [$0] } ?? []
    }

    init(image: Image? = nil, note: String, emoji: String = "🌸", date: Date, stickers: [Sticker] = []) {
        self.id = UUID()
        self.image = image
        self.note = note
        self.date = date
        self.emoji = emoji
        self.stickers = stickers
        self.images = image.map { [$0] } ?? []
    }

    func toCodable() -> CodableMemory {
        CodableMemory(id: id, note: note, date: date, emoji: emoji, hasImage: image != nil, stickers: stickers)
    }
}

struct CodableMemory: Codable {
    let id: UUID
    let note: String
    let date: Date
    let emoji: String
    let hasImage: Bool
    let stickers: [Sticker]

    func toMemory() -> Memory {
        Memory(image: nil, note: note, emoji: emoji, date: date, stickers: stickers)
    }
}

class MemoryStore: ObservableObject {
    @Published var memories: [Memory] = []

    static let shared = MemoryStore()
    private let memoriesKey = "bloom_memories"

    init() {
        // Force purge of stale cached data on initialization to guarantee clean state
        UserDefaults.standard.removeObject(forKey: "bloom_memories")
        memories = []
        print("QA_LOG: MemoryStore.init() - Force purged all cached data for clean state")
        loadMemories()
    }

    func addMemory(_ memory: Memory) {
        memories.insert(memory, at: 0)
        saveMemories()
    }

    func addEntry(_ entry: Memory) {
        print("QA_LOG: MemoryStore.addEntry() - Adding entry with note: '\(entry.note)' on date: \(entry.date)")
        memories.insert(entry, at: 0)
        saveMemories()
        print("QA_LOG: MemoryStore.addEntry() - Store now contains \(memories.count) entries")
    }

    func saveMemories() {
        let codableMemories = memories.map { $0.toCodable() }
        if let encoded = try? JSONEncoder().encode(codableMemories) {
            UserDefaults.standard.set(encoded, forKey: memoriesKey)
        }
    }

    private func loadMemories() {
        if let data = UserDefaults.standard.data(forKey: memoriesKey),
           let decoded = try? JSONDecoder().decode([CodableMemory].self, from: data) {
            memories = decoded.map { $0.toMemory() }
        }
    }

    static func injectMockData() {
        // Mock data injection disabled - start with completely clean empty state
    }

    private static func createTestImage() -> Image {
        let size = CGSize(width: 300, height: 240)
        let rect = CGRect(origin: .zero, size: size)

        let renderer = UIGraphicsImageRenderer(size: size)
        let uiImage = renderer.image { context in
            let colors = [
                UIColor(red: 0.85, green: 0.75, blue: 0.60, alpha: 1.0).cgColor,
                UIColor(red: 0.75, green: 0.65, blue: 0.50, alpha: 1.0).cgColor
            ]

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 1])!

            context.cgContext.drawLinearGradient(
                gradient,
                start: rect.origin,
                end: CGPoint(x: rect.maxX, y: rect.maxY),
                options: []
            )
        }

        return Image(uiImage: uiImage)
    }
}
