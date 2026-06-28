import SwiftUI
import Combine

struct Memory: Identifiable {
    let id: UUID
    let image: Image?
    let note: String
    let date: Date
    let emoji: String

    init(image: Image? = nil, note: String, emoji: String = "🌸") {
        self.id = UUID()
        self.image = image
        self.note = note
        self.date = Date()
        self.emoji = emoji
    }

    init(image: Image? = nil, note: String, emoji: String = "🌸", date: Date) {
        self.id = UUID()
        self.image = image
        self.note = note
        self.date = date
        self.emoji = emoji
    }

    func toCodable() -> CodableMemory {
        CodableMemory(id: id, note: note, date: date, emoji: emoji, hasImage: image != nil)
    }
}

struct CodableMemory: Codable {
    let id: UUID
    let note: String
    let date: Date
    let emoji: String
    let hasImage: Bool

    func toMemory() -> Memory {
        Memory(image: nil, note: note, emoji: emoji)
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
        print("QA_LOG: Memory Added -> \(memory.note)")
        saveMemories()
    }

    private func saveMemories() {
        let codableMemories = memories.map { $0.toCodable() }
        if let encoded = try? JSONEncoder().encode(codableMemories) {
            UserDefaults.standard.set(encoded, forKey: memoriesKey)
            print("QA_LOG: Memories persisted to UserDefaults")
        }
    }

    private func loadMemories() {
        if let data = UserDefaults.standard.data(forKey: memoriesKey),
           let decoded = try? JSONDecoder().decode([CodableMemory].self, from: data) {
            memories = decoded.map { $0.toMemory() }
            print("QA_LOG: \(memories.count) memories loaded from UserDefaults")
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
        print("QA_LOG: Mock data injected - \(shared.memories.count) memories added")
    }
}
