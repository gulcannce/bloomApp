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
}

class MemoryStore: ObservableObject {
    @Published var memories: [Memory] = []

    static let shared = MemoryStore()

    func addMemory(_ memory: Memory) {
        memories.insert(memory, at: 0)
        print("QA_LOG: Memory Added -> \(memory.note)")
    }
}
