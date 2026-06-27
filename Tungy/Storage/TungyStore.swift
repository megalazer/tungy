import Foundation

final class TungyStore {
    static let appGroupSuiteName = "group.com.tungy.app"
    static let shared = TungyStore()

    private enum Keys {
        static let flashcardDecks = "flashcards.decks.v1"
    }
    let defaults: UserDefaults
    let isUsingFallbackDefaults: Bool

    init(suiteName: String = TungyStore.appGroupSuiteName, fallbackDefaults: UserDefaults = .standard) {
        if !suiteName.isEmpty, let suiteDefaults = UserDefaults(suiteName: suiteName) {
            self.defaults = suiteDefaults
            self.isUsingFallbackDefaults = false
        } else {
            self.defaults = fallbackDefaults
            self.isUsingFallbackDefaults = true
        }
    }

    func data(forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }

    func setData(_ data: Data?, forKey key: String) {
        if let data {
            defaults.set(data, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }

    func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    func loadCodable<Value: Decodable>(_ type: Value.Type, forKey key: String, decoder: JSONDecoder = JSONDecoder()) -> Value? {
        guard let data = data(forKey: key) else { return nil }
        return try? decoder.decode(Value.self, from: data)
    }

    func saveCodable<Value: Encodable>(_ value: Value, forKey key: String, encoder: JSONEncoder = JSONEncoder()) throws {
        let data = try encoder.encode(value)
        setData(data, forKey: key)
    }

    func loadDecks() -> [Deck] {
        loadCodable([Deck].self, forKey: Keys.flashcardDecks) ?? []
    }

    func saveDecks(_ decks: [Deck]) throws {
        try saveCodable(decks, forKey: Keys.flashcardDecks)
    }
}
