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
    let image: Image?
    var note: String
    let date: Date
    let emoji: String
    var stickers: [Sticker] = []

    init(image: Image? = nil, note: String, emoji: String = "🌸", stickers: [Sticker] = []) {
        self.id = UUID()
        self.image = image
        self.note = note
        self.date = Date()
        self.emoji = emoji
        self.stickers = stickers
    }

    init(image: Image? = nil, note: String, emoji: String = "🌸", date: Date, stickers: [Sticker] = []) {
        self.id = UUID()
        self.image = image
        self.note = note
        self.date = date
        self.emoji = emoji
        self.stickers = stickers
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
        let mockData: [(note: String, emoji: String, daysAgo: Int)] = [
            ("Bu sabah çok güzel bir kahvaltı yaptım. Evde yaptığım omlet çok lezzetliydi ve hava da harika. Pencereden dışarıyı seyrettim.", "🌸", 9),
            ("Bugün harika bir gün. Parkta yürüyüş yaptım ve doğayı gözlemledim.", "✨", 8),
            ("Evet, bugün biraz tedirgin hissettim fakat sonunda her şey yolunda gitti. Rahatladım.", "☁️", 7),
            ("Yeni bir proje başladım. Çok heyecan duyuyorum. Bu proje bana çok ilham veriyor ve gelişmemi sağlayacak.", "🌱", 6),
            ("Arkadaşlarımla buluştuk ve çok eğlendik. Muhabbet çok güzeldi.", "🤍", 5),
            ("Bugün çok verimli bir gün oldu. Bitirmek istediğim işleri bitirdim.", "🌸", 4),
            ("Sabah antrenmanı yaptım. Vücudum çok güçlü hissetti.", "✨", 3),
            ("Kitap okuduk. Çok hoş bir kitapdı.", "🌱", 2),
            ("Bugün düşündüm. Hayatımı gözden geçirdim.", "☁️", 1),
            ("Bugün güzel bir gün. Evde rahat ettim.", "🤍", 0)
        ]

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for (note, emoji, daysAgo) in mockData {
            let memoryDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
            let memory = Memory(image: nil, note: note, emoji: emoji, date: memoryDate)
            shared.memories.insert(memory, at: 0)
        }

        shared.saveMemories()
    }
}
